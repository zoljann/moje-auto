using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class OrderStatusUpdateRequest
    {
        [MaxLength(50)]
        public string Name { get; set; } = null!;
    }
}