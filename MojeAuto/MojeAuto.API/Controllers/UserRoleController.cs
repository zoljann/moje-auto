using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [Authorize(Roles = "Admin")]
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
