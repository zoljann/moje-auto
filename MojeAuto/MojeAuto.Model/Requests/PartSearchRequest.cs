namespace MojeAuto.Model.Requests
{
    public class PartSearchRequest : BaseSearchRequest
    {
        public string? Name { get; set; }
        public string? CatalogNumber { get; set; }
        public int? WarrantyMonths { get; set; }
        public int? TotalSold { get; set; }
    }
}