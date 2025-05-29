using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("delivery-method")]
    public class DeliveryMethodController : BaseCrudController<DeliveryMethod, DeliveryMethodSearchRequest, DeliveryMethodInsertRequest, DeliveryMethodUpdateRequest>
    {
        public DeliveryMethodController(IBaseCrudService<DeliveryMethod, DeliveryMethodSearchRequest, DeliveryMethodInsertRequest, DeliveryMethodUpdateRequest> service)
            : base(service)
        {
        }
    }
}