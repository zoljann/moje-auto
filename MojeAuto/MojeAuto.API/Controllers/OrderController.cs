using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("orders")]
    public class OrderController : BaseCrudController<Order, OrderSearchRequest, OrderInsertRequest, OrderUpdateRequest>
    {
        private readonly StripeService _stripeService;

        public OrderController(IBaseCrudService<Order, OrderSearchRequest, OrderInsertRequest, OrderUpdateRequest> service, StripeService stripeService)
            : base(service)
        {
            _stripeService = stripeService;
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

        [HttpPost("stripe")]
        public async Task<IActionResult> CreateStripeIntent([FromBody] StripePaymentRequest request)
        {
            var result = await _stripeService.CreatePaymentIntent(request.Amount);
            return Ok(result);
        }
    }
}