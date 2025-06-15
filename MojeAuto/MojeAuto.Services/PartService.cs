using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;
using MojeAuto.Services.RabbitMq;
using MojeAuto.Services.RabbitMq.Messages;
using System.Linq.Expressions;

public class PartService : BaseCrudService<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest>
{
    private readonly IRabbitMqPublisher _mqPublisher;

    public PartService(MojeAutoContext context, IRabbitMqPublisher mqPublisher) : base(context)
    {
        _mqPublisher = mqPublisher;
    }

    public override async Task<ServiceResult<IEnumerable<Part>>> Get(PartSearchRequest search, int? id = null)
    {
        var query = _context.Parts
            .Include(p => p.Manufacturer)
            .Include(p => p.Category)
            .AsQueryable();

        var isDeletedProp = typeof(Part).GetProperty("IsDeleted");
        if (isDeletedProp != null && isDeletedProp.PropertyType == typeof(bool))
        {
            var param = Expression.Parameter(typeof(Part), "p");
            var propAccess = Expression.Property(param, "IsDeleted");
            var falseConstant = Expression.Constant(false);
            var condition = Expression.Equal(propAccess, falseConstant);
            var lambda = Expression.Lambda<Func<Part, bool>>(condition, param);
            query = query.Where(lambda);
        }

        if (search.CarId.HasValue)
        {
            query = query.Where(p =>
                _context.PartCars.Any(pc => pc.PartId == p.PartId && pc.CarId == search.CarId));
        }

        if (id.HasValue)
        {
            var entity = await query
                .Include(p => p.CompatibleCars!)
                    .ThenInclude(pc => pc.Car)
                .FirstOrDefaultAsync(p => p.PartId == id.Value);

            if (entity == null)
                return ServiceResult<IEnumerable<Part>>.Fail("Part not found.");
            return ServiceResult<IEnumerable<Part>>.Ok(new List<Part> { entity });
        }

        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            var term = $"%{search.Name.Trim()}%";
            query = query.Where(p =>
                EF.Functions.Like(p.Name, term) ||
                EF.Functions.Like(p.CatalogNumber, term));
        }

        if (search.CategoryIds != null && search.CategoryIds.Any())
            query = query.Where(p => search.CategoryIds.Contains(p.CategoryId));

        if (search.ManufacturerIds != null && search.ManufacturerIds.Any())
            query = query.Where(p => search.ManufacturerIds.Contains(p.ManufacturerId));

        var searchProps = typeof(PartSearchRequest).GetProperties();
        foreach (var prop in searchProps)
        {
            if (prop.Name is nameof(PartSearchRequest.Name)
                || prop.Name == nameof(PartSearchRequest.CategoryIds)
                || prop.Name == nameof(PartSearchRequest.ManufacturerIds)
                || prop.Name == nameof(PartSearchRequest.CarId))
                continue;

            var value = prop.GetValue(search);
            if (value == null) continue;

            var entityProp = typeof(Part).GetProperty(prop.Name);
            if (entityProp == null) continue;

            var parameter = Expression.Parameter(typeof(Part), "p");
            var left = Expression.Property(parameter, entityProp);
            var right = Expression.Constant(value);

            Expression body;
            if (entityProp.PropertyType == typeof(string))
            {
                var containsMethod = typeof(string).GetMethod("Contains", new[] { typeof(string) })!;
                body = Expression.Call(left, containsMethod, right);
            }
            else
            {
                body = Expression.Equal(left, right);
            }

            var predicate = Expression.Lambda<Func<Part, bool>>(body, parameter);
            query = query.Where(predicate);
        }

        if (search.SortByPriceEnabled)
        {
            query = search.SortByPriceDescending == true
                ? query.OrderByDescending(p => p.Price)
                : query.OrderBy(p => p.Price);
        }
        else
        {
            query = query.OrderByDescending(p => p.PartId);
        }

        if (search.Page > 0 && search.PageSize > 0)
        {
            int skip = (search.Page - 1) * search.PageSize;
            query = query.Skip(skip).Take(search.PageSize + 1);
        }

        var result = await query.ToListAsync();
        return ServiceResult<IEnumerable<Part>>.Ok(result);
    }

    public override async Task<ServiceResult<Part>> Insert(PartInsertRequest insertRequest)
    {
        var manufacturerExists = await _context.Manufacturers.AnyAsync(m => m.ManufacturerId == insertRequest.ManufacturerId);
        var categoryExists = await _context.Categories.AnyAsync(c => c.CategoryId == insertRequest.CategoryId);

        if (!manufacturerExists)
            return ServiceResult<Part>.Fail("Invalid ManufacturerId");

        if (!categoryExists)
            return ServiceResult<Part>.Fail("Invalid CategoryId");

        if (decimal.TryParse(
       insertRequest.Price.ToString().Replace(',', '.'),
       System.Globalization.NumberStyles.Any,
       System.Globalization.CultureInfo.InvariantCulture,
       out var parsedPrice))
        {
            insertRequest.Price = parsedPrice;
        }

        var part = new Part();
        MapInsertRequestToEntity(insertRequest, part);

        if (insertRequest.Image != null && insertRequest.Image.Length > 0)
        {
            using var ms = new MemoryStream();
            await insertRequest.Image.CopyToAsync(ms);
            part.ImageData = ms.ToArray();
        }

        _dbSet.Add(part);
        await _context.SaveChangesAsync();

        return ServiceResult<Part>.Ok(part);
    }

    public override async Task<ServiceResult<Part>> Update(int id, PartUpdateRequest updateRequest)
    {
        var part = await _dbSet.FindAsync(id);
        if (part == null)
            return ServiceResult<Part>.Fail("Part not found.");

        var previousQuantity = part.Quantity;

        if (decimal.TryParse(
        updateRequest.Price.ToString().Replace(',', '.'),
        System.Globalization.NumberStyles.Any,
        System.Globalization.CultureInfo.InvariantCulture,
        out var parsedPrice))
        {
            updateRequest.Price = parsedPrice;
        }

        MapUpdateRequestToEntity(updateRequest, part);

        if (updateRequest.Image != null && updateRequest.Image.Length > 0)
        {
            using var ms = new MemoryStream();
            await updateRequest.Image.CopyToAsync(ms);
            part.ImageData = ms.ToArray();
        }

        if (previousQuantity == 0 && part.Quantity > 0)
        {
            var subscriptions = await _context.PartAvailabilitySubscriptions
                .Where(s => s.PartId == part.PartId && !s.IsNotified)
                .ToListAsync();

            foreach (var sub in subscriptions)
            {
                var msg = new NotifyAvailabilityMessage
                {
                    PartId = part.PartId,
                    UserId = sub.UserId
                };

                _mqPublisher.Publish(msg, "part-available");
                sub.IsNotified = true;
            }
        }

        await _context.SaveChangesAsync();
        return ServiceResult<Part>.Ok(part);
    }
}