using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("cars")]
    public class CarsController : BaseCrudController<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>
    {
        public CarsController(IBaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest> service)
            : base(service)
        {
        }
    }
}
