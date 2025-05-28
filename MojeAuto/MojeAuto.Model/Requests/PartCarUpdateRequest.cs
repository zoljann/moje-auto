using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class PartCarUpdateRequest
    {
        public int PartId { get; set; }
        public int CarId { get; set; }
    }
}