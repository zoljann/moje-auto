using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class NotificationUpdateRequest
    {
        public int UserId { get; set; }

        [MaxLength(500)]
        public string Message { get; set; } = null!;

        public bool IsRead { get; set; }
    }
}