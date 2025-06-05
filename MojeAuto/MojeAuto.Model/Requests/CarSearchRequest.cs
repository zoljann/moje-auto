namespace MojeAuto.Model.Requests
{
    public class CarSearchRequest : BaseSearchRequest
    {
        public string? VIN { get; set; }
        public string? Brand { get; set; }
        public string? Model { get; set; }
        public string? Engine { get; set; }
        public string? Fuel { get; set; }
        public int? Year { get; set; }
    }
}