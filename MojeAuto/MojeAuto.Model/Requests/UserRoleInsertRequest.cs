using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class UserRoleInsertRequest
    {
        [Required, MaxLength(30)]
        public string Name { get; set; } = null!;
    }
}