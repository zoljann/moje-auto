using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MojeAuto.Model;
using MojeAuto.Services.Database;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CarsController : ControllerBase
    {
        private readonly MojeAutoContext _context;

        public CarsController(MojeAutoContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Cars>>> Get()
        {
            var cars = await _context.Cars.ToListAsync();
            return Ok(cars);
        }
    }
}
