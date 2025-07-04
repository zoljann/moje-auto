using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class RezervacijaProstoraInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int RadniProstorId { get; set; }

        [Required]
        public DateTime DatumPocetka { get; set; }

        [Required]
        public int Trajanje { get; set; }

        [Required]
        public string Status { get; set; } = null!;

        [Required]
        public string Napomena { get; set; } = null!;
    }
}