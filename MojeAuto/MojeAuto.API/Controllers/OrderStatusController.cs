using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("order-status")]
    public class OrderStatusController : BaseCrudController<OrderStatus, OrderStatusSearchRequest, OrderStatusInsertRequest, OrderStatusUpdateRequest>
    {
        public OrderStatusController(IBaseCrudService<OrderStatus, OrderStatusSearchRequest, OrderStatusInsertRequest, OrderStatusUpdateRequest> service)
            : base(service)
        {
        }
    }
}
