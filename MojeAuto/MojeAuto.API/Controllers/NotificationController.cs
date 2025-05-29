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
    }
}
