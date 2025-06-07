using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class DeliveryInsertRequest
    {
        public DateTime? DeliveryDate { get; set; }

        [Required]
        public int DeliveryMethodId { get; set; }

        [Required]
        public int DeliveryStatusId { get; set; }
    }
}
