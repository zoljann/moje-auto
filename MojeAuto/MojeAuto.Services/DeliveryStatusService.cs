using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class DeliveryStatusService : BaseCrudService<DeliveryStatus, DeliveryStatusSearchRequest, DeliveryStatusInsertRequest, DeliveryStatusUpdateRequest>
{
    public DeliveryStatusService(MojeAutoContext context) : base(context)
    {
    }
}