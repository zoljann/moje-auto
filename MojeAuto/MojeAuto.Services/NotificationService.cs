using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class NotificationService : BaseCrudService<Notification, NotificationSearchRequest, NotificationInsertRequest, NotificationUpdateRequest>
{
    public NotificationService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<Notification>> Insert(NotificationInsertRequest insertRequest)
    {
        var userExists = await _context.Users.AnyAsync(u => u.UserId == insertRequest.UserId);

        if (!userExists)
        {
            return ServiceResult<Notification>.Fail("Invalid UserId");
        }

        var notification = new Notification();
        MapInsertRequestToEntity(insertRequest, notification);

        notification.DateCreated = DateTime.Now;

        _dbSet.Add(notification);
        await _context.SaveChangesAsync();

        return ServiceResult<Notification>.Ok(notification);
    }
}