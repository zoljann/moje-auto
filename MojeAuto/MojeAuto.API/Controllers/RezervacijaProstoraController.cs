using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("rezervacija-prostora")]
    public class RezervacijaProstoraController : BaseCrudController<RezervacijaProstora, RezervacijaProstoraSearchRequest, RezervacijaProstoraInsertRequest, RezervacijaProstoraUpdateRequest>
    {
        public RezervacijaProstoraController(IBaseCrudService<RezervacijaProstora, RezervacijaProstoraSearchRequest, RezervacijaProstoraInsertRequest, RezervacijaProstoraUpdateRequest> service)
            : base(service)
        {
        }

        [AllowAnonymous]
        [HttpGet]
        public override async Task<ActionResult<IEnumerable<RezervacijaProstora>>> Get([FromQuery] RezervacijaProstoraSearchRequest search, [FromQuery] int? id = null)
        {
            return await base.Get(search, id);
        }

        [AllowAnonymous]
        [HttpPost]
        public override async Task<ActionResult<RezervacijaProstora>> Insert([FromForm] RezervacijaProstoraInsertRequest insertRequest)
        {
            return await base.Insert(insertRequest);
        }

        [AllowAnonymous]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromForm] RezervacijaProstoraUpdateRequest updateRequest)
        {
            return await base.Update(id, updateRequest);
        }
    }
}