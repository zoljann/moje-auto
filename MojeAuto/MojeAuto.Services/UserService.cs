using Microsoft.EntityFrameworkCore;
using MojeAuto.Services.Database;

public class UserService : BaseCrudService<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest>
{
    public UserService(MojeAutoContext context) : base(context) { 
    }
    public override async Task<User> Insert(UserInsertRequest insertRequest)
    {

        var user = new User();

        MapInsertRequestToEntity(insertRequest, user);
        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(insertRequest.Password);
        user.UserRoleId = 1;

        _dbSet.Add(user);
        await _context.SaveChangesAsync();

        return user;
    }
}
