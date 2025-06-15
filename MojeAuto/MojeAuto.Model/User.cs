using System.ComponentModel.DataAnnotations;

public class User
{
    public int UserId { get; set; }

    [Required, MaxLength(50)]
    public string FirstName { get; set; } = null!;

    [Required, MaxLength(50)]
    public string LastName { get; set; } = null!;

    [Required, EmailAddress, MaxLength(100)]
    public string Email { get; set; } = null!;

    [Required]
    public string PasswordHash { get; set; } = null!;

    [Required, MaxLength(100)]
    public string Address { get; set; } = null!;

    [Required, MaxLength(20)]
    public string PhoneNumber { get; set; } = null!;

    [Required]
    public DateTime BirthDate { get; set; }

    [Required]
    public int UserRoleId { get; set; }

    public UserRole UserRole { get; set; } = null!;

    [Required]
    public int CountryId { get; set; }

    public Country Country { get; set; } = null!;
    public byte[]? ImageData { get; set; }
    public bool IsDeleted { get; set; } = false;

    public ICollection<Order>? Orders { get; set; }
    public ICollection<AdminReport>? AdminReports { get; set; }
}