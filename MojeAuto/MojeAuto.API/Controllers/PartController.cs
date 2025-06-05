using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("parts")]
    public class PartController : BaseCrudController<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest>
    {
        public PartController(IBaseCrudService<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest> service)
            : base(service)
        {
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<ActionResult<Part>> Insert([FromForm] PartInsertRequest request)
        {
            var result = await _service.Insert(request);
            if (!result.Success)
                return BadRequest(result.ErrorMessage);

            return Ok(result.Data);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromForm] PartUpdateRequest request)
        {
            var result = await _service.Update(id, request);
            if (!result.Success)
                return BadRequest(result.ErrorMessage);

            return Ok(result.Data);
        }
    }
}