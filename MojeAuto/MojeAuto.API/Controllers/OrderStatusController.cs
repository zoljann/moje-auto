using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("order-statuses")]
    public class OrderStatusController : BaseCrudController<OrderStatus, OrderStatusSearchRequest, OrderStatusInsertRequest, OrderStatusUpdateRequest>
    {
        public OrderStatusController(IBaseCrudService<OrderStatus, OrderStatusSearchRequest, OrderStatusInsertRequest, OrderStatusUpdateRequest> service)
            : base(service)
        {
        }
    }
}