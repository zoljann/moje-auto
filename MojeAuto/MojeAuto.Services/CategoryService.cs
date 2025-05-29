using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class CategoryService : BaseCrudService<Category, CategorySearchRequest, CategoryInsertRequest, CategoryUpdateRequest>
{
    public CategoryService(MojeAutoContext context) : base(context)
    {
    }
}