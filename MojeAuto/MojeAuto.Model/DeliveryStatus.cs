using System.ComponentModel.DataAnnotations;

public class DeliveryStatus
{
    public int DeliveryStatusId { get; set; }

    [Required, MaxLength(50)]
    public string Name { get; set; } = null!;
}
