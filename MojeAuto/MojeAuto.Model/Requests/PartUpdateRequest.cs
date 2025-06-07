using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class PartUpdateRequest
    {
        [MaxLength(100)]
        public string Name { get; set; } = null!;

        [MaxLength(100)]
        public string CatalogNumber { get; set; } = null!;

        [MaxLength(500)]
        public string? Description { get; set; }

        [MaxLength(500)]
        public string? Weight { get; set; }

        public decimal Price { get; set; }
        public int WarrantyMonths { get; set; }
        public int Quantity { get; set; }
        public int CategoryId { get; set; }
        public IFormFile? Image { get; set; }

        public int EstimatedArrivalDays { get; set; }
    }
}