using System.ComponentModel.DataAnnotations;

public class Transakcija25062025

{
    public int Transakcija25062025Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public decimal Amount { get; set; }
    public DateTime Datum { get; set; }
    public string Opis { get; set; } = null!;
    public int KategorijaTransakcije25062025Id { get; set; }
    public KategorijaTransakcije25062025 KategorijaTransakcije { get; set; } = null!;
    public string Status { get; set; } = null!;
}