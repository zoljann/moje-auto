using System.ComponentModel.DataAnnotations;

public class PartCar
{
    [Key]
    public int PartCarId { get; set; }

    [Required]
    public int PartId { get; set; }

    [Required]
    public int CarId { get; set; }

    public Part Part { get; set; } = null!;
    public Car Car { get; set; } = null!;
}