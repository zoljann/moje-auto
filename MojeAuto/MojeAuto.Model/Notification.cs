using System.ComponentModel.DataAnnotations;

public class Notification
{
    public int NotificationId { get; set; }

    [Required]
    public int UserId { get; set; }

    [Required, MaxLength(500)]
    public string Message { get; set; } = null!;

    [Required, MaxLength(50)]
    public string Type { get; set; } = null!;

    [Required]
    public DateTime DateCreated { get; set; } = DateTime.Now;

    public bool IsRead { get; set; } = false;

    public User User { get; set; } = null!;
}