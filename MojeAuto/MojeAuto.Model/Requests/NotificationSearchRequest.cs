namespace MojeAuto.Model.Requests
{
    public class NotificationSearchRequest : BaseSearchRequest
    {
        public string? UserId { get; set; }
        public bool? IsRead { get; set; }
    }
}