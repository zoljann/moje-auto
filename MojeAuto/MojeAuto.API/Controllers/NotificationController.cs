using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

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
    }
}
