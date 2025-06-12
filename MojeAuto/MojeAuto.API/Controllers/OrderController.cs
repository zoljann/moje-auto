using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("orders")]
    public class OrderController : BaseCrudController<Order, OrderSearchRequest, OrderInsertRequest, OrderUpdateRequest>
    {
        public OrderController(IBaseCrudService<Order, OrderSearchRequest, OrderInsertRequest, OrderUpdateRequest> service)
            : base(service)
        {
        }

        [AllowAnonymous]
        [HttpPost]
        public override async Task<ActionResult<Order>> Insert([FromBody] OrderInsertRequest insertRequest)
        {
            return await base.Insert(insertRequest);
        }

        [AllowAnonymous]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromBody] OrderUpdateRequest updateRequest)
        {
            return await base.Update(id, updateRequest);
        }

    }
}