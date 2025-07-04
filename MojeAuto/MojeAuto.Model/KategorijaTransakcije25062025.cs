using System.ComponentModel.DataAnnotations;

public class KategorijaTransakcije25062025
{
    public int KategorijaTransakcije25062025Id { get; set; }
    public string NazivKategorije { get; set; } = null!;
    public string TipKategorije { get; set; } = null!; //prihod, rashod itd
}