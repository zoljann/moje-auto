using System.ComponentModel.DataAnnotations;

public class Delivery
{
    public int DeliveryId { get; set; }

    [Required]
    public int OrderId { get; set; }

    public DateTime DeliveryDate { get; set; }

    [Required]
    public int DeliveryMethodId { get; set; }

    [Required]
    public int DeliveryStatusId { get; set; }

    public DeliveryMethod DeliveryMethod { get; set; } = null!;
    public DeliveryStatus DeliveryStatus { get; set; } = null!;
}