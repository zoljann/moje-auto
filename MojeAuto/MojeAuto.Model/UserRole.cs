using System.ComponentModel.DataAnnotations;

public class UserRole
{
    public int UserRoleId { get; set; }

    [Required, MaxLength(30)]
    public string Name { get; set; } = null!;

    public ICollection<User>? Users { get; set; }
}