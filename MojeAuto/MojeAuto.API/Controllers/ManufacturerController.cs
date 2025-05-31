using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("manufacturers")]
    public class ManufacturerController : BaseCrudController<Manufacturer, ManufacturerSearchRequest, ManufacturerInsertRequest, ManufacturerUpdateRequest>
    {
        public ManufacturerController(IBaseCrudService<Manufacturer, ManufacturerSearchRequest, ManufacturerInsertRequest, ManufacturerUpdateRequest> service)
            : base(service)
        {
        }
    }
}