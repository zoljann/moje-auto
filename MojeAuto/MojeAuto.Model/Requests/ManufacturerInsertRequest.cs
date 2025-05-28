using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class ManufacturerInsertRequest
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = null!;

        [Required]
        public int CountryId { get; set; }
    }
}