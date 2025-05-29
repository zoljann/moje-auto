using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class CarService : BaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>
{
    public CarService(MojeAutoContext context) : base(context)
    {
    }
}