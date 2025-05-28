using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;

namespace MojeAuto.API.Controllers
{
    [ApiController]
    [Route("payment-method")]
    public class PaymentMethodController : BaseCrudController<PaymentMethod, PaymentMethodSearchRequest, PaymentMethodInsertRequest, PaymentMethodUpdateRequest>
    {
        public PaymentMethodController(IBaseCrudService<PaymentMethod, PaymentMethodSearchRequest, PaymentMethodInsertRequest, PaymentMethodUpdateRequest> service)
            : base(service)
        {
        }
    }
}
