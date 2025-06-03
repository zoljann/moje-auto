namespace MojeAuto.Model.Common
{
    public class RefreshToken
    {
        public int RefreshTokenId { get; set; }
        public string Token { get; set; } = null!;
        public DateTime Expires { get; set; }
        public bool IsRevoked { get; set; }
        public int UserId { get; set; }
        public User User { get; set; } = null!;
    }
}