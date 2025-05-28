using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("manufacturer")]
    public class ManufacturerController : BaseCrudController<Manufacturer, ManufacturerSearchRequest, ManufacturerInsertRequest, ManufacturerUpdateRequest>
    {
        public ManufacturerController(IBaseCrudService<Manufacturer, ManufacturerSearchRequest, ManufacturerInsertRequest, ManufacturerUpdateRequest> service)
            : base(service)
        {
        }
    }
}
