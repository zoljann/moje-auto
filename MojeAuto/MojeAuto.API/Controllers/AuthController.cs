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
        var (token, user) = await _authService.AuthenticateAsync(request);

        if (user == null)
            return Unauthorized("Invalid credentials.");

        return Ok(new
        {
            Token = token,
            User = new
            {
                user.UserId,
                user.FirstName,
                user.LastName,
                user.Email,
            }
        });
    }
}