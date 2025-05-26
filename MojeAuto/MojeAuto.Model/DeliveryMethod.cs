using System.ComponentModel.DataAnnotations;

public class DeliveryMethod
{
    public int DeliveryMethodId { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = null!;

    [MaxLength(500)]
    public string? Description { get; set; }
}
