namespace MojeAuto.Model
{
    public class PartAvailabilitySubscription
    {
        public int Id { get; set; }
        public int PartId { get; set; }
        public int UserId { get; set; }
        public bool IsNotified { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Part Part { get; set; } = null!;
        public User User { get; set; } = null!;
    }
}