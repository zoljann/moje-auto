using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

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

        [Authorize(Roles = "Admin")]
        [HttpGet]
        public override async Task<ActionResult<IEnumerable<User>>> Get([FromQuery] UserSearchRequest search, [FromQuery] int? id = null)
        {
            return await base.Get(search, id);
        }

        [AllowAnonymous]
        [HttpPost]
        public override async Task<ActionResult<User>> Insert([FromBody] UserInsertRequest insertRequest)
        {
            return await base.Insert(insertRequest);
        }

        [AllowAnonymous]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromBody] UserUpdateRequest updateRequest)
        {
            return await base.Update(id, updateRequest);
        }
    }
}
