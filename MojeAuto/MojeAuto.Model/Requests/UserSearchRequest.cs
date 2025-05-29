namespace MojeAuto.Model.Requests
{
    public class UserSearchRequest : BaseSearchRequest
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public int? CountryId { get; set; }
    }
}