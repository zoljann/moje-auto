using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class PartCarService : BaseCrudService<PartCar, PartCarSearchRequest, PartCarInsertRequest, PartCarUpdateRequest>
{
    public PartCarService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<IEnumerable<PartCar>>> Get(PartCarSearchRequest search, int? id = null)
    {
        var query = _context.PartCars
            .Include(x => x.Part)
            .Include(x => x.Car)
            .AsQueryable();

        if (id.HasValue)
        {
            var single = await query.FirstOrDefaultAsync(x => x.PartCarId == id.Value);
            if (single == null)
                return ServiceResult<IEnumerable<PartCar>>.Fail("Entity not found.");

            return ServiceResult<IEnumerable<PartCar>>.Ok(new List<PartCar> { single });
        }

        if (search.PartId.HasValue)
            query = query.Where(x => x.PartId == search.PartId.Value);

        if (search.CarId.HasValue)
            query = query.Where(x => x.CarId == search.CarId.Value);

        var list = await query.ToListAsync();

        if (!list.Any())
            return ServiceResult<IEnumerable<PartCar>>.Fail("No results found.");

        return ServiceResult<IEnumerable<PartCar>>.Ok(list);
    }

    public override async Task<ServiceResult<PartCar>> Insert(PartCarInsertRequest insertRequest)
    {
        var partExists = await _context.Parts.AnyAsync(p => p.PartId == insertRequest.PartId);
        if (!partExists)
        {
            return ServiceResult<PartCar>.Fail("Invalid PartId");
        }

        var carExists = await _context.Cars.AnyAsync(c => c.CarId == insertRequest.CarId);
        if (!carExists)
        {
            return ServiceResult<PartCar>.Fail("Invalid CarId");
        }

        var exists = await _context.PartCars
            .AnyAsync(pc => pc.PartId == insertRequest.PartId && pc.CarId == insertRequest.CarId);

        if (exists)
        {
            return ServiceResult<PartCar>.Fail("This part is already linked to this car.");
        }

        var entity = new PartCar();
        MapInsertRequestToEntity(insertRequest, entity);

        _dbSet.Add(entity);
        await _context.SaveChangesAsync();

        return ServiceResult<PartCar>.Ok(entity);
    }
}