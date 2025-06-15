using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

public class Manufacturer
{
    public int ManufacturerId { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = null!;

    [Required]
    public int CountryId { get; set; }

    public Country Country { get; set; } = null!;
    public bool IsDeleted { get; set; } = false;

    [JsonIgnore]
    public ICollection<Part>? Parts { get; set; }
}