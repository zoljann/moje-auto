using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model;

[ApiController]
[Route("login")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var (token, refreshToken, user) = await _authService.AuthenticateAsync(request);

        if (user == null)
            return Unauthorized("Invalid credentials.");

        return Ok(new
        {
            Token = token,
            RefreshToken = refreshToken,
            User = new
            {
                user.UserId,
                user.FirstName,
                user.LastName,
                user.Email,
            }
        });
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] string refreshToken)
    {
        var (newToken, newRefreshToken) = await _authService.RefreshAsync(refreshToken);

        if (string.IsNullOrEmpty(newToken))
            return Unauthorized("Invalid or expired refresh token.");

        return Ok(new
        {
            Token = newToken,
            RefreshToken = newRefreshToken
        });
    }
}