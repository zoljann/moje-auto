﻿using System.ComponentModel.DataAnnotations;

public class OrderStatus
{
    public int OrderStatusId { get; set; }

    [Required, MaxLength(50)]
    public string Name { get; set; } = null!;

    public bool IsDeleted { get; set; } = false;
}