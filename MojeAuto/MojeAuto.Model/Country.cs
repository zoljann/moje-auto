using System.ComponentModel.DataAnnotations;

public class Country
{
    public int CountryId { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = null!;

    [MaxLength(3)]
    public string? ISOCode { get; set; }

    public bool IsDeleted { get; set; } = false;
}