using System.ComponentModel.DataAnnotations;

public class Car
{
    public int CarId { get; set; }

    [Required, MaxLength(50)]
    public string VIN { get; set; } = null!;

    [Required, MaxLength(50)]
    public string Brand { get; set; } = null!;

    [Required, MaxLength(50)]
    public string Model { get; set; } = null!;

    [Required]
    public double Engine { get; set; }

    [Required, MaxLength(50)]
    public string Fuel { get; set; } = null!;

    [Required]
    public int Year { get; set; }

    public ICollection<PartCar>? CompatibleParts { get; set; }
}