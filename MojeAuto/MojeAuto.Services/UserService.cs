using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Services.Database;

public class UserService : BaseCrudService<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest>
{
    public UserService(MojeAutoContext context) : base(context) { 
    }
    public override async Task<ServiceResult<User>> Insert(UserInsertRequest insertRequest)
    {
        var countryExists = await _context.Countries.AnyAsync(c => c.CountryId == insertRequest.CountryId);
        
        if (!countryExists)
        {
            return ServiceResult<User>.Fail("Invalid CountryId");
        }

        var userRole = await _context.UserRoles.FirstOrDefaultAsync(r => r.Name.ToLower() == "user");

        if (userRole == null)
        {
            return ServiceResult<User>.Fail("User role not found");

        }

        var user = new User();

        MapInsertRequestToEntity(insertRequest, user);
        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(insertRequest.Password);
        user.UserRoleId = 1;

        _dbSet.Add(user);
        await _context.SaveChangesAsync();

        return ServiceResult<User>.Ok(user);
    }
}
