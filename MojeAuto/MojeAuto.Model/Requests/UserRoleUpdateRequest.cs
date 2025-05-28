using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class UserRoleUpdateRequest
    {
        [MaxLength(30)]
        public string Name { get; set; } = null!;
    }
}