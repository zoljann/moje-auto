using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class CategoryInsertRequest
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = null!;

        [MaxLength(500)]
        public string? Description { get; set; }
    }
}