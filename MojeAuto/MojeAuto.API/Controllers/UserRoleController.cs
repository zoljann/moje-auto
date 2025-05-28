using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("user-role")]
    public class UserRoleController : BaseCrudController<UserRole, UserRoleSearchRequest, UserRoleInsertRequest, UserRoleUpdateRequest>
    {
        public UserRoleController(IBaseCrudService<UserRole, UserRoleSearchRequest, UserRoleInsertRequest, UserRoleUpdateRequest> service)
            : base(service)
        {
        }
    }
}
