using System.ComponentModel.DataAnnotations;

public class OrderItem
{
    public int OrderItemId { get; set; }
    
    [Required]
    public int OrderId { get; set; }

    [Required]
    public int PartId { get; set; }

    [Required]
    public int Quantity { get; set; }

    [Required]
    public decimal UnitPrice { get; set; }

    public Part? Part { get; set; }
}