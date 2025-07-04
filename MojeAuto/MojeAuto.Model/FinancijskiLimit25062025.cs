using System.ComponentModel.DataAnnotations;

public class FinancijskiLimit25062025
{
    public int FinancijskiLimit25062025Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public decimal Limit { get; set; }
    public int Mjesec { get; set; }
    public int KategorijaTransakcije25062025Id { get; set; }
    public KategorijaTransakcije25062025 KategorijaTransakcije { get; set; } = null!;
}