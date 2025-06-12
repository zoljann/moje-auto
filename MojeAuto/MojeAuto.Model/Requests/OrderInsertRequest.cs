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

    public string? PaymentReference { get; set; }

    [Required]
    public List<OrderItemInsertRequest> OrderItems { get; set; } = new();
}