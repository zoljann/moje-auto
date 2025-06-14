using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;
using System.Linq.Expressions;

public class CarService : BaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>
{
    public CarService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<IEnumerable<Car>>> Get(CarSearchRequest search, int? id = null)
    {
        if (id.HasValue)
        {
            var entity = await _dbSet.FindAsync(id.Value);
            if (entity == null)
                return ServiceResult<IEnumerable<Car>>.Fail("Entity not found.");

            return ServiceResult<IEnumerable<Car>>.Ok(new List<Car> { entity });
        }

        var query = _dbSet.AsQueryable();

        if (!string.IsNullOrWhiteSpace(search.Brand))
        {
            var q = search.Brand.ToLower();
            query = query.Where(c =>
                c.Brand.ToLower().Contains(q) ||
                c.Model.ToLower().Contains(q) ||
                c.VIN.ToLower().Contains(q));
        }

        var searchProps = typeof(CarSearchRequest).GetProperties();
        foreach (var prop in searchProps)
        {
            if (prop.Name == nameof(CarSearchRequest.Brand) || prop.Name == nameof(CarSearchRequest.Model))
                continue;

            var value = prop.GetValue(search);
            if (value == null) continue;

            var entityProp = typeof(Car).GetProperty(prop.Name);
            if (entityProp == null) continue;

            var parameter = Expression.Parameter(typeof(Car), "e");
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

            var predicate = Expression.Lambda<Func<Car, bool>>(body, parameter);
            query = query.Where(predicate);
        }

        if (search is BaseSearchRequest pagination && pagination.Page > 0 && pagination.PageSize > 0)
        {
            int skip = (pagination.Page - 1) * pagination.PageSize;
            query = query.Skip(skip).Take(pagination.PageSize + 1);
        }

        var list = await query
    .OrderByDescending(c => c.CarId)
    .ToListAsync();
        if (!list.Any())
            return ServiceResult<IEnumerable<Car>>.Fail("No results found.");

        return ServiceResult<IEnumerable<Car>>.Ok(list);
    }

    public override async Task<ServiceResult<Car>> Insert(CarInsertRequest insertRequest)
    {
        var vinExists = await _context.Cars.AnyAsync(c => c.VIN == insertRequest.VIN);
        if (vinExists)
            return ServiceResult<Car>.Fail("A car with this VIN already exists.");

        var car = new Car();
        MapInsertRequestToEntity(insertRequest, car);

        if (insertRequest.Image != null && insertRequest.Image.Length > 0)
        {
            using var ms = new MemoryStream();
            await insertRequest.Image.CopyToAsync(ms);
            car.ImageData = ms.ToArray();
        }

        _dbSet.Add(car);
        await _context.SaveChangesAsync();

        return ServiceResult<Car>.Ok(car);
    }

    public override async Task<ServiceResult<Car>> Update(int id, CarUpdateRequest updateRequest)
    {
        var car = await _dbSet.FindAsync(id);
        if (car == null)
            return ServiceResult<Car>.Fail("Car not found.");

        var vinExists = await _context.Cars.AnyAsync(c => c.VIN == updateRequest.VIN && c.CarId != id);
        if (vinExists)
            return ServiceResult<Car>.Fail("Another car with this VIN already exists.");

        MapUpdateRequestToEntity(updateRequest, car);

        if (updateRequest.Image != null && updateRequest.Image.Length > 0)
        {
            using var ms = new MemoryStream();
            await updateRequest.Image.CopyToAsync(ms);
            car.ImageData = ms.ToArray();
        }

        await _context.SaveChangesAsync();
        return ServiceResult<Car>.Ok(car);
    }
}