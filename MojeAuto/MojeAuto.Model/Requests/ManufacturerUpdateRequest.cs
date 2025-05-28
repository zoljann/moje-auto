using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class ManufacturerUpdateRequest
    {
        [MaxLength(100)]
        public string Name { get; set; } = null!;

        public int CountryId { get; set; }
    }
}