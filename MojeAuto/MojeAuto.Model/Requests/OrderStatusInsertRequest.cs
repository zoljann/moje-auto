using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class OrderStatusInsertRequest
    {
         [Required, MaxLength(50)]
        public string Name { get; set; } = null!;
    }
}