using System.ComponentModel.DataAnnotations;

public class Manufacturer
{
    public int ManufacturerId { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = null!;

    [Required]
    public int CountryId { get; set; }

    public Country Country { get; set; } = null!;

    public ICollection<Part>? Parts { get; set; }
}
