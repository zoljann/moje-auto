using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class CountryService : BaseCrudService<Country, CountrySearchRequest, CountryInsertRequest, CountryUpdateRequest>
{
    public CountryService(MojeAutoContext context) : base(context)
    {
    }
}