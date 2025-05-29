namespace MojeAuto.Model.Requests
{
    public class PartCarSearchRequest : BaseSearchRequest
    {
        public int? PartId { get; set; }
        public int? CarId { get; set; }
    }
}