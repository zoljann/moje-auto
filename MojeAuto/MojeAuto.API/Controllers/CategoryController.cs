using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("category")]
    public class CategoryController : BaseCrudController<Category, CategorySearchRequest, CategoryInsertRequest, CategoryUpdateRequest>
    {
        public CategoryController(IBaseCrudService<Category, CategorySearchRequest, CategoryInsertRequest, CategoryUpdateRequest> service)
            : base(service)
        {
        }
    }
}
