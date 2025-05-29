namespace MojeAuto.Model.Requests
{
    public class CountrySearchRequest : BaseSearchRequest
    {
        public string? Name { get; set; }
        public string? ISOCode { get; set; }
    }
}