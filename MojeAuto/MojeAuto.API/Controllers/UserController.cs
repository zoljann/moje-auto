using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("users")]
    public class UserController : BaseCrudController<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IBaseCrudService<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest> service)
            : base(service)
        {
        }
    }
}
