﻿using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class OrderUpdateRequest
    {
        [Required]
        public int OrderStatusId { get; set; }

        public int? PaymentMethodId { get; set; }

        public DeliveryUpdateRequest? Delivery { get; set; }
    }
}