using System.ComponentModel.DataAnnotations;

public class PartCar
{
    [Key]
    public int PartCarId { get; set; }
    public int PartId { get; set; }
    public Part Part { get; set; } = null!;

    public int CarId { get; set; }
    public Car Car { get; set; } = null!;
}