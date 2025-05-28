using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class CountryUpdateRequest
    {
        [MaxLength(100)]
        public string Name { get; set; } = null!;

        [MaxLength(3)]
        public string? ISOCode { get; set; }
    }
}