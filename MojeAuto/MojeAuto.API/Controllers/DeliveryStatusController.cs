using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("delivery-status")]
    public class DeliveryStatusController : BaseCrudController<DeliveryStatus, DeliveryStatusSearchRequest, DeliveryStatusInsertRequest, DeliveryStatusUpdateRequest>
    {
        public DeliveryStatusController(IBaseCrudService<DeliveryStatus, DeliveryStatusSearchRequest, DeliveryStatusInsertRequest, DeliveryStatusUpdateRequest> service)
            : base(service)
        {
        }
    }
}
