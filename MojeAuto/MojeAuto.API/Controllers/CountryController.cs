using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("country")]
    public class CountryController : BaseCrudController<Country, CountrySearchRequest, CountryInsertRequest, CountryUpdateRequest>
    {
        public CountryController(IBaseCrudService<Country, CountrySearchRequest, CountryInsertRequest, CountryUpdateRequest> service)
            : base(service)
        {
        }
    }
}
