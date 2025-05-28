using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class PaymentMethodService : BaseCrudService<PaymentMethod, PaymentMethodSearchRequest, PaymentMethodInsertRequest, PaymentMethodUpdateRequest>
{
    public PaymentMethodService(MojeAutoContext context) : base(context) { }
}
