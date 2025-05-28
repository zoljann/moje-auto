using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class DeliveryMethodService : BaseCrudService<DeliveryMethod, DeliveryMethodSearchRequest, DeliveryMethodInsertRequest, DeliveryMethodUpdateRequest>
{
    public DeliveryMethodService(MojeAutoContext context) : base(context) { }
}
