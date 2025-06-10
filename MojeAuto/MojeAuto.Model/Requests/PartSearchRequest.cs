namespace MojeAuto.Model.Requests
{
    public class PartSearchRequest : BaseSearchRequest
    {
        public string? Name { get; set; }
        public string? CatalogNumber { get; set; }
        public int? WarrantyMonths { get; set; }
        public int? TotalSold { get; set; }
        public List<int>? CategoryIds { get; set; }
        public List<int>? ManufacturerIds { get; set; }
        public bool SortByPriceDescending { get; set; } = false;
        public bool SortByPriceEnabled { get; set; } = false;
        public int? CarId { get; set; }
    }
}