using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class Transakcija25062025InsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [Required]
        public DateTime Datum { get; set; }

        [Required]
        public string Opis { get; set; } = null!;

        [Required]
        public int KategorijaTransakcije25062025Id { get; set; }

        [Required]
        public string Status { get; set; } = null!;
    }
}