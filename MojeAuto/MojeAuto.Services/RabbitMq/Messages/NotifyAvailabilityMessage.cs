namespace MojeAuto.Services.RabbitMq.Messages
{
    public class NotifyAvailabilityMessage
    {
        public int PartId { get; set; }
        public int UserId { get; set; }
    }
}