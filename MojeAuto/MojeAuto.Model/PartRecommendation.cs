namespace MojeAuto.Model
{
    public class PartRecommendation
    {
        public int PartId { get; set; }
        public int RecommendedPartId { get; set; }
        public float Score { get; set; }

        public Part Part { get; set; } = null!;
        public Part RecommendedPart { get; set; } = null!;
    }
}