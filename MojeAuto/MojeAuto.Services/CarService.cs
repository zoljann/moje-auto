using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class CarService : BaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>
{
    public CarService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<Car>> Insert(CarInsertRequest insertRequest)
    {
        var vinExists = await _context.Cars.AnyAsync(c => c.VIN == insertRequest.VIN);
        if (vinExists)
            return ServiceResult<Car>.Fail("A car with this VIN already exists.");

        var car = new Car();
        MapInsertRequestToEntity(insertRequest, car);

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
        await _context.SaveChangesAsync();

        return ServiceResult<Car>.Ok(car);
    }
}