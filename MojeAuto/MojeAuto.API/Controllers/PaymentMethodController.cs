using Microsoft.AspNetCore.Mvc;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;

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