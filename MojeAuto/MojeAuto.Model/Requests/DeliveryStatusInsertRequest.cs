using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class DeliveryStatusInsertRequest
    {
        [Required, MaxLength(50)]
        public string Name { get; set; } = null!;
    }
}