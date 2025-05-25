namespace MojeAuto.Model.Requests
{
    public class CarUpdateRequest
    {
        public string Name { get; set; } = null!;
        public string Make { get; set; } = null!;
        public string Model { get; set; } = null!;
        public int Year { get; set; }
        public string? Color { get; set; }
    }
}
