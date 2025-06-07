using MojeAuto.Model.Requests;
using System.ComponentModel.DataAnnotations;

public class OrderInsertRequest
{
    [Required]
    public int UserId { get; set; }

    [Required]
    public int PaymentMethodId { get; set; }

    [Required]
    public DeliveryInsertRequest Delivery { get; set; } = null!;

    [Required]
    public List<OrderItem> OrderItems { get; set; } = new();
}