using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class NotificationInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required, MaxLength(500)]
        public string Message { get; set; } = null!;

        public bool IsRead { get; set; } = false;
    }
}