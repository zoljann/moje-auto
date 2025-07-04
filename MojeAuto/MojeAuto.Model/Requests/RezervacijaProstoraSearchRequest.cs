namespace MojeAuto.Model.Requests
{
    public class RezervacijaProstoraSearchRequest : BaseSearchRequest
    {
        public int? UserId { get; set; }
        public int? RadniProstorId { get; set; }
        public string? Status { get; set; }
    }
}