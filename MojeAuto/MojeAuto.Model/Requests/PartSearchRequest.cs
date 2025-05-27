namespace MojeAuto.Model.Requests
{
    public class PartSearchRequest
    {
        public string? Name { get; set; }
        public string? CatalogNumber { get; set; }
        public int? WarrantyMonths { get; set; }
        public int? TotalSold { get; set; }
    }
}