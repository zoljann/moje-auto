using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;
using System.Linq.Expressions;

public class UserService : BaseCrudService<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest>
{
    public UserService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<IEnumerable<User>>> Get(UserSearchRequest search, int? id = null)
    {
        if (id.HasValue)
        {
            var entity = await _dbSet.FindAsync(id.Value);
            if (entity == null)
                return ServiceResult<IEnumerable<User>>.Fail("User not found.");

            return ServiceResult<IEnumerable<User>>.Ok(new List<User> { entity });
        }

        var query = _dbSet.AsQueryable();

        if (!string.IsNullOrWhiteSpace(search.FirstName))
        {
            var q = search.FirstName.ToLower();
            query = query.Where(u =>
                u.FirstName.ToLower().Contains(q) ||
                u.LastName.ToLower().Contains(q));
        }

        var searchProps = typeof(UserSearchRequest).GetProperties();
        foreach (var prop in searchProps)
        {
            if (prop.Name == nameof(UserSearchRequest.FirstName) || prop.Name == nameof(UserSearchRequest.LastName))
                continue;

            var value = prop.GetValue(search);
            if (value == null) continue;

            var entityProp = typeof(User).GetProperty(prop.Name);
            if (entityProp == null) continue;

            var parameter = Expression.Parameter(typeof(User), "u");
            var left = Expression.Property(parameter, entityProp);
            var right = Expression.Constant(value);

            Expression body;
            if (entityProp.PropertyType == typeof(string))
            {
                var containsMethod = typeof(string).GetMethod("Contains", new[] { typeof(string) })!;
                body = Expression.Call(left, containsMethod, right);
            }
            else
            {
                body = Expression.Equal(left, right);
            }

            var predicate = Expression.Lambda<Func<User, bool>>(body, parameter);
            query = query.Where(predicate);
        }

        if (search is BaseSearchRequest pagination && pagination.Page > 0 && pagination.PageSize > 0)
        {
            int skip = (pagination.Page - 1) * pagination.PageSize;
            query = query.Skip(skip).Take(pagination.PageSize);
        }

        var list = await query.ToListAsync();
        if (!list.Any())
            return ServiceResult<IEnumerable<User>>.Fail("No results found.");

        return ServiceResult<IEnumerable<User>>.Ok(list);
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

        var user = new User();

        MapInsertRequestToEntity(insertRequest, user);

        if (insertRequest.Image != null && insertRequest.Image.Length > 0)
        {
            using var ms = new MemoryStream();
            await insertRequest.Image.CopyToAsync(ms);
            user.ImageData = ms.ToArray();
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(insertRequest.Password);

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

        if (updateRequest.Image != null && updateRequest.Image.Length > 0)
        {
            using var ms = new MemoryStream();
            await updateRequest.Image.CopyToAsync(ms);
            user.ImageData = ms.ToArray();
        }

        await _context.SaveChangesAsync();

        return ServiceResult<User>.Ok(user);
    }
}