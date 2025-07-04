using System.ComponentModel.DataAnnotations;

public class TransakcijaLog25062025

{
    public int TransakcijaLog25062025Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string StariStatus { get; set; } = null!;
    public string NoviStatus { get; set; } = null!;
    public DateTime VrijemePromjene { get; set; } = DateTime.Now;
}