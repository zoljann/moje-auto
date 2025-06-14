namespace MojeAuto.Model
{
    public class InitialRecommendation
    {
        public int InitialRecommendationId { get; set; }
        public int PartId { get; set; }
        public Part Part { get; set; } = null!;
    }
}