using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class UserUpdateRequest
    {
        [MaxLength(50)]
        public string? FirstName { get; set; }

        [MaxLength(50)]
        public string? LastName { get; set; }

        [EmailAddress, MaxLength(100)]
        public string? Email { get; set; }

        public string? Password { get; set; }

        [MaxLength(100)]
        public string? Address { get; set; }

        [MaxLength(20)]
        public string? PhoneNumber { get; set; }

        public DateTime? BirthDate { get; set; }

        public int? UserRoleId { get; set; }
        public int? CountryId { get; set; }
        public IFormFile? Image { get; set; }
    }
}