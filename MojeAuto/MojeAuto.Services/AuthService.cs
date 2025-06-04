using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using MojeAuto.Model.Common;
using MojeAuto.Model;
using MojeAuto.Services.Database;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;

public class AuthService : IAuthService
{
    private readonly MojeAutoContext _context;
    private readonly IConfiguration _config;

    public AuthService(MojeAutoContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    public async Task<(string Token, string RefreshToken, User? User)> AuthenticateAsync(LoginRequest request)
    {
        var user = await _context.Users
            .Include(u => u.UserRole)
            .FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return default;

        var token = GenerateJwtToken(user);
        var refreshToken = await GenerateRefreshToken(user);

        return (token, refreshToken.Token, user);
    }

    private async Task<RefreshToken> GenerateRefreshToken(User user)
    {
        var refreshToken = new RefreshToken
        {
            Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
            Expires = DateTime.UtcNow.AddDays(7),
            IsRevoked = false,
            UserId = user.UserId
        };

        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        return refreshToken;
    }

    public async Task<(string Token, string RefreshToken)> RefreshAsync(string refreshToken)
    {
        var storedToken = await _context.RefreshTokens
          .Include(rt => rt.User)
          .ThenInclude(u => u.UserRole)
          .FirstOrDefaultAsync(rt => rt.Token == refreshToken && rt.Expires > DateTime.UtcNow && !rt.IsRevoked);

        if (storedToken == null || storedToken.User == null)
            return default;

        storedToken.IsRevoked = true;
        var newJwt = GenerateJwtToken(storedToken.User);
        var newRefresh = await GenerateRefreshToken(storedToken.User);

        await _context.SaveChangesAsync();

        return (newJwt, newRefresh.Token);
    }

    private string GenerateJwtToken(User user)
    {
        var keyString = Environment.GetEnvironmentVariable("JWT_KEY") ?? throw new Exception("JWT_KEY environment variable is not set.");
        var issuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? throw new Exception("JWT_ISSUER environment variable is not set.");
        var audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? throw new Exception("JWT_AUDIENCE environment variable is not set.");
        var expiresInString = Environment.GetEnvironmentVariable("JWT_EXPIRESINMINUTES") ?? throw new Exception("JWT_EXPIRESINMINUTES environment variable is not set.");

        if (!int.TryParse(expiresInString, out int expiresInMinutes))
            throw new Exception("JWT_EXPIRESINMINUTES must be a valid integer.");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Email),
            new Claim(ClaimTypes.Name, user.Email),
            new Claim("userId", user.UserId.ToString()),
            new Claim(ClaimTypes.Role, user.UserRole?.Name ?? "User")
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