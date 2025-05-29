using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseCrudController<TEntity, TSearch, TInsert, TUpdate> : ControllerBase
        where TEntity : class
    {
        protected readonly IBaseCrudService<TEntity, TSearch, TInsert, TUpdate> _service;

        public BaseCrudController(IBaseCrudService<TEntity, TSearch, TInsert, TUpdate> service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual async Task<ActionResult<IEnumerable<TEntity>>> Get([FromQuery] TSearch search, [FromQuery] int? id = null)
        {
            var result = await _service.Get(search, id);

            if (!result.Success || result.Data == null)
                return NotFound(new { error = result.ErrorMessage ?? "No data found." });

            if (id.HasValue)
            {
                var singleEntity = result.Data.FirstOrDefault();
                if (singleEntity == null)
                    return NotFound();

                return Ok(singleEntity);
            }

            return Ok(result.Data);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public virtual async Task<ActionResult<TEntity>> Insert([FromBody] TInsert insertRequest)
        {
            var result = await _service.Insert(insertRequest);

            if (!result.Success)
                return BadRequest(new { error = result.ErrorMessage });

            return Ok();
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Update(int id, [FromBody] TUpdate updateRequest)
        {
            var result = await _service.Update(id, updateRequest);

            if (!result.Success)
                return BadRequest(new { error = result.ErrorMessage });

            return NoContent();
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            var result = await _service.Delete(id);

            if (!result.Success)
                return NotFound(new { error = result.ErrorMessage });

            return NoContent();
        }
    }
}