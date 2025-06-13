using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Requests;
using MojeAuto.Services;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("availability-subscriptions")]
    public class AvailabilitySubscriptionsController : ControllerBase
    {
        private readonly AvailabilitySubscriptionService _service;

        public AvailabilitySubscriptionsController(AvailabilitySubscriptionService service)
        {
            _service = service;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] AvailabilitySubscriptionInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return result.Success ? Ok(result) : BadRequest(result.ErrorMessage);
        }
    }
}