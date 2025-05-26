using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class CarInsertRequest
    {
        [Required, MaxLength(50)]
        public string VIN { get; set; } = null!;

        [Required, MaxLength(50)]
        public string Brand { get; set; } = null!;

        [Required, MaxLength(50)]
        public string Model { get; set; } = null!;

        [Required]
        public int Year { get; set; }
    }
}