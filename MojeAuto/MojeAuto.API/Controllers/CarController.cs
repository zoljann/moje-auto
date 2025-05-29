using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("cars")]
    public class CarController : BaseCrudController<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>
    {
        public CarController(IBaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest> service)
            : base(service)
        {
        }
    }
}