namespace MojeAuto.Model.Requests
{
    public class DeliveryUpdateRequest
    {
        public int? DeliveryMethodId { get; set; }
        public int? DeliveryStatusId { get; set; }
        public DateTime? DeliveryDate { get; set; }
    }
}
