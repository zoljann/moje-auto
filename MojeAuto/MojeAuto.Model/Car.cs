using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

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
    public string Engine { get; set; }

    [Required, MaxLength(50)]
    public string Fuel { get; set; } = null!;

    [Required]
    public int Year { get; set; }

    public byte[]? ImageData { get; set; }
    [JsonIgnore]
    public ICollection<PartCar>? CompatibleParts { get; set; }
}