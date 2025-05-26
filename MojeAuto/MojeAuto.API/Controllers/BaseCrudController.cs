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
            var entities = await _service.Get(search, id);

            if (id.HasValue)
            {
                var singleEntity = entities.FirstOrDefault();
                if (singleEntity == null) return NotFound();
                return Ok(singleEntity);
            }

            return Ok(entities);
        }


        [HttpPost]
        public virtual async Task<ActionResult<TEntity>> Insert([FromBody] TInsert insertRequest)
        {
            var result = await _service.Insert(insertRequest);

            if (!result.Success)
                return BadRequest(new { error = result.ErrorMessage });

            return CreatedAtAction(nameof(Get), new { id = GetEntityId(result.Data!) }, result.Data);
        }

        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Update(int id, [FromBody] TUpdate updateRequest)
        {
            var result = await _service.Update(id, updateRequest);

            if (!result.Success)
                return BadRequest(new { error = result.ErrorMessage });

            return NoContent();
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            var result = await _service.Delete(id);

            if (!result.Success)
                return NotFound(new { error = result.ErrorMessage });

            return NoContent();
        }

        private object? GetEntityId(TEntity entity)
        {
            var prop = typeof(TEntity).GetProperty("Id");

            return prop?.GetValue(entity);
        }
    }
}
