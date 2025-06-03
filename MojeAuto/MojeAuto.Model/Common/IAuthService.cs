using MojeAuto.Model;

public interface IAuthService
{
    Task<(string Token, string RefreshToken, User? User)> AuthenticateAsync(LoginRequest request);

    Task<(string Token, string RefreshToken)> RefreshAsync(string refreshToken);
}