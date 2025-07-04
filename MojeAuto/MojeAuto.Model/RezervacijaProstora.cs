using System.ComponentModel.DataAnnotations;

public class RezervacijaProstora
{
    public int RezervacijaProstoraId { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int RadniProstorId { get; set; }
    public RadniProstor RadniProstor { get; set; } = null!;
    public DateTime DatumPocetka { get; set; }

    public int Trajanje { get; set; }
    public string Status { get; set; } = null!;
    public string Napomena { get; set; } = null!;
}