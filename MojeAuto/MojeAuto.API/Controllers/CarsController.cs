using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model;
using MojeAuto.Model.Requests;
using MojeAuto.Services;
using System.Collections.Generic;
using System.Threading.Tasks;

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
