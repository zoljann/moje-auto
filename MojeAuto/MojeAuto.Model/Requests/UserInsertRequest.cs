using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class UserInsertRequest
    {
        [Required, MaxLength(50)]
        public string FirstName { get; set; } = null!;

        [Required, MaxLength(50)]
        public string LastName { get; set; } = null!;

        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = null!;

        [Required]
        public string Password { get; set; } = null!;

        [Required, MaxLength(100)]
        public string Address { get; set; } = null!;

        [Required, MaxLength(20)]
        public string PhoneNumber { get; set; } = null!;

        [Required]
        public DateTime BirthDate { get; set; }

        [MaxLength(100)]
        public string? AvatarUrl { get; set; }

        [Required]
        public int CountryId { get; set; }
    }
}