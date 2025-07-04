using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class Transakcija25062025UpdateRequest
    {
        public int UserId { get; set; }
        public string Status { get; set; } = null!;
        public string Opis { get; set; } = null!;
        public int KategorijaTransakcije25062025Id { get; set; }
    }
}