using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class OrderStatusService : BaseCrudService<OrderStatus, OrderStatusSearchRequest, OrderStatusInsertRequest, OrderStatusUpdateRequest>
{
    public OrderStatusService(MojeAutoContext context) : base(context)
    {
    }
}