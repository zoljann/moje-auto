using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class CarSearchRequest
    {
        public string? VIN { get; set; }
        public string? Brand { get; set; }
        public string? Model { get; set; }
        public int? Year { get; set; }
    }
}
