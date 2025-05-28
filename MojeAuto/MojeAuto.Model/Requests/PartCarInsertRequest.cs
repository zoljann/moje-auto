using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class PartCarInsertRequest
    {
        [Required]
        public int PartId { get; set; }

        [Required]
        public int CarId { get; set; }
    }
}