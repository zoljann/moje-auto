using MojeAuto.Model.Common;
using MojeAuto.Model;
using MojeAuto.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace MojeAuto.Services
{
    public class RecommenderService
    {
        private readonly MojeAutoContext _context;

        public RecommenderService(MojeAutoContext context)
        {
            _context = context;
        }

        public async Task<ServiceResult<bool>> TrainModelAsync()
        {
            var parts = await _context.Parts.AsNoTracking().ToListAsync();

            var recommendations = new List<PartRecommendation>();

            foreach (var part in parts)
            {
                var similarParts = parts
                    .Where(p => p.PartId != part.PartId)
                    .Select(p => new
                    {
                        Part = p,
                        Score = CalculateSimilarity(part, p)
                    })
                    .OrderByDescending(x => x.Score)
                    .Take(3)
                    .ToList();

                foreach (var sim in similarParts)
                {
                    recommendations.Add(new PartRecommendation
                    {
                        PartId = part.PartId,
                        RecommendedPartId = sim.Part.PartId,
                        Score = sim.Score
                    });
                }
            }

            _context.PartRecommendations.RemoveRange(_context.PartRecommendations);
            await _context.PartRecommendations.AddRangeAsync(recommendations);
            await _context.SaveChangesAsync();

            return ServiceResult<bool>.Ok(true);
        }

        public async Task<ServiceResult<IEnumerable<Part>>> GetRecommendationsAsync(int partId)
        {
            var exists = await _context.Parts.AnyAsync(p => p.PartId == partId);
            if (!exists)
                return ServiceResult<IEnumerable<Part>>.Fail("Invalid PartId.");

            var recommendations = await _context.PartRecommendations
                .Where(r => r.PartId == partId)
                .OrderByDescending(r => r.Score)
                .Select(r => r.RecommendedPart)
                .ToListAsync();

            if (!recommendations.Any())
                return ServiceResult<IEnumerable<Part>>.Fail("Nema preporuka.");

            return ServiceResult<IEnumerable<Part>>.Ok(recommendations);
        }

        public async Task<ServiceResult<IEnumerable<Part>>> GetPersonalizedRecommendationsAsync(int userId)
        {
            var recentOrderedPartIds = await _context.Orders
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.OrderDate)
                .SelectMany(o => o.OrderItems.Select(oi => oi.PartId))
                .Distinct()
                .Take(3)
                .ToListAsync();

            var recommended = await _context.PartRecommendations
                .Where(r => recentOrderedPartIds.Contains(r.PartId))
                .OrderByDescending(r => r.Score)
                .Select(r => r.RecommendedPart)
                .Distinct()
                .Take(9)
                .ToListAsync();

            return ServiceResult<IEnumerable<Part>>.Ok(recommended);
        }

        public async Task<ServiceResult<IEnumerable<Part>>> GetInitialRecommendationsAsync()
        {
            var topRecommended = await _context.PartRecommendations
                .GroupBy(r => r.RecommendedPartId)
                .Select(g => new
                {
                    PartId = g.Key,
                    ScoreSum = g.Sum(x => x.Score)
                })
                .OrderByDescending(x => x.ScoreSum)
                .Take(5)
                .ToListAsync();

            var scoredIds = topRecommended.Select(x => x.PartId).ToList();

            var scoredParts = await _context.Parts
                .Where(p => scoredIds.Contains(p.PartId))
                .Include(p => p.Manufacturer)
                .Include(p => p.Category)
                .ToListAsync();

            var initialManualParts = await _context.InitialRecommendations
                .Include(ir => ir.Part)
                    .ThenInclude(p => p.Manufacturer)
                .Include(ir => ir.Part)
                    .ThenInclude(p => p.Category)
                .Select(ir => ir.Part)
                .ToListAsync();

            var combined = scoredParts
                .Concat(initialManualParts)
                .GroupBy(p => p.PartId)
                .Select(g => g.First())
                .ToList();

            return ServiceResult<IEnumerable<Part>>.Ok(combined);
        }

        private float CalculateSimilarity(Part a, Part b)
        {
            float score = 0;

            if (a.CategoryId == b.CategoryId) score += 1;
            if (a.ManufacturerId == b.ManufacturerId) score += 1;

            var priceDiff = Math.Abs(a.Price - b.Price);
            var maxPrice = Math.Max(a.Price, b.Price);
            if (maxPrice > 0)
                score += 1 - (float)(priceDiff / maxPrice);

            var warrantyDiff = Math.Abs(a.WarrantyMonths - b.WarrantyMonths);
            var maxWarranty = Math.Max(a.WarrantyMonths, b.WarrantyMonths);
            if (maxWarranty > 0)
                score += 1 - (float)warrantyDiff / maxWarranty;

            return score;
        }
    }
}