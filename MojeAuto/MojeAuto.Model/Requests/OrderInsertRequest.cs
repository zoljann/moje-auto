using System.ComponentModel.DataAnnotations;

public class OrderInsertRequest
{
    [Required]
    public int UserId { get; set; }

    [Required]
    public int PaymentMethodId { get; set; }

    [Required]
    public int DeliveryId { get; set; }

    [Required]
    public List<OrderItem> OrderItems { get; set; } = new();
}