using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("notification")]
    public class NotificationController : BaseCrudController<Notification, NotificationSearchRequest, NotificationInsertRequest, NotificationUpdateRequest>
    {
        public NotificationController(IBaseCrudService<Notification, NotificationSearchRequest, NotificationInsertRequest, NotificationUpdateRequest> service)
            : base(service)
        {
        }

        [AllowAnonymous]
        [HttpPost]
        public override async Task<ActionResult<Notification>> Insert([FromBody] NotificationInsertRequest insertRequest)
        {
            return await base.Insert(insertRequest);
        }

        [AllowAnonymous]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromBody] NotificationUpdateRequest updateRequest)
        {
            return await base.Update(id, updateRequest);
        }
    }
}