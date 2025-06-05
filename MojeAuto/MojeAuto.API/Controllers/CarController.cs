using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("cars")]
    public class CarController : BaseCrudController<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>
    {
        public CarController(IBaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest> service)
            : base(service)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<ActionResult<Car>> Insert([FromForm] CarInsertRequest request)
        {
            var result = await _service.Insert(request);
            if (!result.Success)
                return BadRequest(result.ErrorMessage);

            return Ok(result.Data);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Update(int id, [FromForm] CarUpdateRequest request)
        {
            var result = await _service.Update(id, request);
            if (!result.Success)
                return BadRequest(result.ErrorMessage);

            return Ok(result.Data);
        }
    }
}