using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("transakcija")]
    public class Transakcija25062025Controller : BaseCrudController<Transakcija25062025, Transakcija25062025SearchRequest, Transakcija25062025InsertRequest, Transakcija25062025UpdateRequest>
    {
        public Transakcija25062025Controller(IBaseCrudService<Transakcija25062025, Transakcija25062025SearchRequest, Transakcija25062025InsertRequest, Transakcija25062025UpdateRequest> service)
            : base(service)
        {
        }

        [AllowAnonymous]
        [HttpGet]
        public override async Task<ActionResult<IEnumerable<Transakcija25062025>>> Get([FromQuery] Transakcija25062025SearchRequest search, [FromQuery] int? id = null)
        {
            return await base.Get(search, id);
        }

        [AllowAnonymous]
        [HttpPost]
        public override async Task<ActionResult<Transakcija25062025>> Insert([FromForm] Transakcija25062025InsertRequest insertRequest)
        {
            return await base.Insert(insertRequest);
        }

        [AllowAnonymous]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromForm] Transakcija25062025UpdateRequest updateRequest)
        {
            return await base.Update(id, updateRequest);
        }
    }
}