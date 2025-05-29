using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("part")]
    public class PartController : BaseCrudController<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest>
    {
        public PartController(IBaseCrudService<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest> service)
            : base(service)
        {
        }
    }
}