using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class UserRoleService : BaseCrudService<UserRole, UserRoleSearchRequest, UserRoleInsertRequest, UserRoleUpdateRequest>
{
    public UserRoleService(MojeAutoContext context) : base(context)
    {
    }
}