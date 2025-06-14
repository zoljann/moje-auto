﻿using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace MojeAuto.Model.Requests
{
    public class CarUpdateRequest
    {
        [MaxLength(50)]
        public string? VIN { get; set; }

        [MaxLength(50)]
        public string? Brand { get; set; }

        [MaxLength(50)]
        public string? Model { get; set; }

        public string? Engine { get; set; }

        [MaxLength(50)]
        public string? Fuel { get; set; }

        public int? Year { get; set; }

        public IFormFile? Image { get; set; }
    }
}