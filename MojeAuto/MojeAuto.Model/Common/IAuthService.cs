using MojeAuto.Model;

public interface IAuthService
{
    Task<(string Token, User? User)> AuthenticateAsync(LoginRequest request);
}