using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

public class Category
{
    public int CategoryId { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = null!;

    [MaxLength(500)]
    public string? Description { get; set; }

    [JsonIgnore]
    public ICollection<Part>? Parts { get; set; }
}