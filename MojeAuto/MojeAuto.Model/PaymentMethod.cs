using System.ComponentModel.DataAnnotations;

public class PaymentMethod
{
    public int PaymentMethodId { get; set; }

    [Required, MaxLength(50)]
    public string Name { get; set; } = null!;

    public ICollection<Order>? Orders { get; set; }
}