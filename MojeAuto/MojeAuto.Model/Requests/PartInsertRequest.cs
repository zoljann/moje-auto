using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class PartInsertRequest
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = null!;

        [Required, MaxLength(100)]
        public string CatalogNumber { get; set; } = null!;

        [MaxLength(500)]
        public string? Description { get; set; }

        [MaxLength(500)]
        public string? Weight { get; set; }

        [Required]
        public decimal Price { get; set; }

        [Required]
        public int WarrantyMonths { get; set; }

        [Required]
        public int Quantity { get; set; }

        [Required]
        public int TotalSold { get; set; }

        [Required]
        public int ManufacturerId { get; set; }

        [Required]
        public int CategoryId { get; set; }

        public IFormFile? Image { get; set; }
        public int EstimatedArrivalDays { get; set; }
    }
}