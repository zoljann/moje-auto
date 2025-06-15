using Microsoft.EntityFrameworkCore;
using MojeAuto.Model;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

namespace MojeAuto.Services
{
    public class AvailabilitySubscriptionService
    {
        private readonly MojeAutoContext _context;

        public AvailabilitySubscriptionService(MojeAutoContext context)
        {
            _context = context;
        }

        public async Task<ServiceResult<object>> InsertAsync(AvailabilitySubscriptionInsertRequest request)
        {
            var alreadySubscribed = await _context.PartAvailabilitySubscriptions
                .AnyAsync(x => x.PartId == request.PartId && x.UserId == request.UserId && !x.IsNotified);

            if (alreadySubscribed)
                return ServiceResult<object>.Fail("Već ste pretplaćeni na notifikaciju za ovaj dio.");

            var entity = new PartAvailabilitySubscription
            {
                PartId = request.PartId,
                UserId = request.UserId,
                CreatedAt = DateTime.UtcNow
            };

            _context.PartAvailabilitySubscriptions.Add(entity);
            await _context.SaveChangesAsync();

            return ServiceResult<object>.Ok(null!);
        }
    }
}