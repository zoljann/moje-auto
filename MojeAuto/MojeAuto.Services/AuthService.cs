using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using MojeAuto.Model;
using MojeAuto.Services.Database;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

public class AuthService : IAuthService
{
    private readonly MojeAutoContext _context;
    private readonly IConfiguration _config;

    public AuthService(MojeAutoContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    public async Task<(string Token, User? User)> AuthenticateAsync(LoginRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return default;

        var token = GenerateJwtToken(user);

        return (token, user);
    }

    private string GenerateJwtToken(User user)
    {
        var jwtSettings = _config.GetSection("Jwt");

        var keyString = jwtSettings["Key"] ?? throw new Exception("JWT Key is not configured.");
        var issuer = jwtSettings["Issuer"] ?? throw new Exception("JWT Issuer is not configured.");
        var audience = jwtSettings["Audience"] ?? throw new Exception("JWT Audience is not configured.");
        var expiresInString = jwtSettings["ExpiresInMinutes"] ?? throw new Exception("JWT ExpiresInMinutes is not configured.");

        if (!int.TryParse(expiresInString, out int expiresInMinutes))
            throw new Exception("JWT ExpiresInMinutes config value is not a valid integer.");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
        new Claim(JwtRegisteredClaimNames.Sub, user.Email),
        new Claim("userId", user.UserId.ToString()),
        new Claim("role", user.UserRole?.Name ?? "User"),
    };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiresInMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

}
