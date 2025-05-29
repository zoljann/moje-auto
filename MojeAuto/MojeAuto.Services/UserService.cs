using Azure.Core;
using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class UserService : BaseCrudService<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest>
{
    public UserService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<User>> Insert(UserInsertRequest insertRequest)
    {
        var userWithEmailExist = await _context.Users.AnyAsync(u => u.Email == insertRequest.Email);
        if (userWithEmailExist)
            return ServiceResult<User>.Fail("Email is already in use.");

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
        user.UserRoleId = userRole.UserRoleId;

        _dbSet.Add(user);
        await _context.SaveChangesAsync();

        return ServiceResult<User>.Ok(user);
    }

    public override async Task<ServiceResult<User>> Update(int id, UserUpdateRequest updateRequest)
    {
        var user = await _dbSet.FindAsync(id);
        if (user == null)
            return ServiceResult<User>.Fail("User not found.");

        var emailTaken = await _context.Users.AnyAsync(u => u.Email == updateRequest.Email && u.UserId != id);
        if (emailTaken)
            return ServiceResult<User>.Fail("Email is already in use by another user.");

        if (updateRequest.CountryId != null)
        {
            var countryExists = await _context.Countries.AnyAsync(c => c.CountryId == updateRequest.CountryId);
            if (!countryExists)
                return ServiceResult<User>.Fail("Invalid CountryId.");
        }

        MapUpdateRequestToEntity(updateRequest, user);
        await _context.SaveChangesAsync();

        return ServiceResult<User>.Ok(user);
    }
}