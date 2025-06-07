namespace MojeAuto.Model.Requests
{
    public class OrderSearchRequest : BaseSearchRequest
    {
        public int? UserId { get; set; }

        public DateTime? FromDate { get; set; }

        public DateTime? ToDate { get; set; }

        public int? OrderStatusId { get; set; }

        public string? User { get; set; }
    }
}