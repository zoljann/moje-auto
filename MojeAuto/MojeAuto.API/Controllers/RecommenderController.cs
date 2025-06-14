using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Services;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("recommender")]
    public class RecommenderController : ControllerBase
    {
        private readonly RecommenderService _service;

        public RecommenderController(RecommenderService service)
        {
            _service = service;
        }

        [HttpGet("recommend/{partId}")]
        public async Task<IActionResult> GetRecommendations(int partId)
        {
            var result = await _service.GetRecommendationsAsync(partId);
            if (!result.Success)
                return NotFound(new { error = result.ErrorMessage });

            return Ok(result.Data);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("train")]
        public async Task<IActionResult> Train()
        {
            var result = await _service.TrainModelAsync();
            if (!result.Success)
                return BadRequest(new { error = result.ErrorMessage });

            return Ok(new { message = "Recommendation training completed." });
        }

        [HttpGet("personalized/{userId}")]
        public async Task<IActionResult> GetPersonalized(int userId)
        {
            var result = await _service.GetPersonalizedRecommendationsAsync(userId);

            if (!result.Success || result.Data == null || !result.Data.Any())
            {
                var fallback = await _service.GetInitialRecommendationsAsync();
                return Ok(fallback.Data);
            }

            return Ok(result.Data);
        }
    }
}