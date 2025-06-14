using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MojeAuto.Model;
using MojeAuto.Services.Database;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("initial-recommendations")]
    public class InitialRecommendationController : ControllerBase
    {
        private readonly MojeAutoContext _context;

        public InitialRecommendationController(MojeAutoContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var parts = await _context.InitialRecommendations
                .Include(ir => ir.Part)
                .Select(ir => ir.Part)
                .ToListAsync();

            return Ok(parts);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("{partId}")]
        public async Task<IActionResult> Add(int partId)
        {
            var exists = await _context.Parts.AnyAsync(p => p.PartId == partId);
            if (!exists)
                return BadRequest(new { error = "Invalid PartId" });

            var alreadyAdded = await _context.InitialRecommendations.AnyAsync(ir => ir.PartId == partId);
            if (alreadyAdded)
                return BadRequest(new { error = "Already in initial recommendations" });

            await _context.InitialRecommendations.AddAsync(new InitialRecommendation { PartId = partId });
            await _context.SaveChangesAsync();

            return Ok(new { message = "Added to initial recommendations." });
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{partId}")]
        public async Task<IActionResult> Delete(int partId)
        {
            var entity = await _context.InitialRecommendations.FirstOrDefaultAsync(ir => ir.PartId == partId);
            if (entity == null)
                return NotFound(new { error = "Not found." });

            _context.InitialRecommendations.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}