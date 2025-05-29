using System.ComponentModel.DataAnnotations;

public class Order
{
    public int OrderId { get; set; }

    [Required]
    public int UserId { get; set; }

    [Required]
    public DateTime OrderDate { get; set; } = DateTime.Now;

    [Required]
    public decimal TotalAmount { get; set; }

    [Required]
    public int PaymentMethodId { get; set; }

    [Required]
    public int OrderStatusId { get; set; }

    [Required]
    public int DeliveryId { get; set; }

    public User User { get; set; } = null!;
    public PaymentMethod PaymentMethod { get; set; } = null!;
    public OrderStatus OrderStatus { get; set; } = null!;
    public Delivery Delivery { get; set; } = null!;
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}