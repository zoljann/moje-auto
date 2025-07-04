using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("radni-prostori")]
    public class RadniProstorController : ControllerBase
    {
        private readonly MojeAutoContext _context;

        public RadniProstorController(MojeAutoContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<RadniProstor>>> GetAll()
        {
            var data = await _context.RadniProstor.ToListAsync();
            return Ok(data);
        }
    }
}