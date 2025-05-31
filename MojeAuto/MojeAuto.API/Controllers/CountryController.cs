using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("countries")]
    public class CountryController : BaseCrudController<Country, CountrySearchRequest, CountryInsertRequest, CountryUpdateRequest>
    {
        public CountryController(IBaseCrudService<Country, CountrySearchRequest, CountryInsertRequest, CountryUpdateRequest> service)
            : base(service)
        {
        }
    }
}