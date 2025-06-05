using System.ComponentModel.DataAnnotations;

public class Part
{
    public int PartId { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = null!;

    [Required, MaxLength(100)]
    public string CatalogNumber { get; set; } = null!;

    [MaxLength(500)]
    public string? Description { get; set; }

    [MaxLength(500)]
    public string? Weight { get; set; }

    [Required]
    public decimal Price { get; set; }

    [Required]
    public int WarrantyMonths { get; set; }

    [Required]
    public int Quantity { get; set; }

    [Required]
    public int TotalSold { get; set; } = 0;

    [Required]
    public int ManufacturerId { get; set; }

    [Required]
    public int CategoryId { get; set; }

    public byte[]? ImageData { get; set; }

    public int EstimatedArrivalDays { get; set; }

    public Manufacturer Manufacturer { get; set; } = null!;
    public Category Category { get; set; } = null!;

    public ICollection<OrderItem>? OrderItems { get; set; }
    public ICollection<PartCar>? CompatibleCars { get; set; }
}