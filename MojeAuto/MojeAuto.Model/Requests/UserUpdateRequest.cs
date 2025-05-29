using System.ComponentModel.DataAnnotations;

public class UserUpdateRequest
{
    [MaxLength(50)]
    public string? FirstName { get; set; }

    [MaxLength(50)]
    public string? LastName { get; set; }

    [EmailAddress, MaxLength(100)]
    public string? Email { get; set; }

    public string? Password { get; set; } // optional, only if user wants to change it

    [MaxLength(100)]
    public string? Address { get; set; }

    [MaxLength(20)]
    public string? PhoneNumber { get; set; }

    public DateTime? BirthDate { get; set; }

    [MaxLength(100)]
    public string? AvatarUrl { get; set; }

    public int? UserRoleId { get; set; }
    public int? CountryId { get; set; }
}