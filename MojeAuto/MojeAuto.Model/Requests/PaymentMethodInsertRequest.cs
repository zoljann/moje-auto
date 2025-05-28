using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class PaymentMethodInsertRequest
    {
       [Required, MaxLength(50)]
        public string Name { get; set; } = null!;
    }
}