using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("part-car")]
    public class PartCarController : BaseCrudController<PartCar, PartCarSearchRequest, PartCarInsertRequest, PartCarUpdateRequest>
    {
        public PartCarController(IBaseCrudService<PartCar, PartCarSearchRequest, PartCarInsertRequest, PartCarUpdateRequest> service)
            : base(service)
        {
        }
    }
}