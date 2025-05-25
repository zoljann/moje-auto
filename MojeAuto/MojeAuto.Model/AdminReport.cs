
using System.ComponentModel.DataAnnotations;

public class AdminReport
{
    public int AdminReportId { get; set; }

    [Required]
    public int UserId { get; set; }

    [Required]
    public int Month { get; set; }

    [Required]
    public int Year { get; set; }

    [Required]
    public decimal TotalSpent { get; set; }

    [Required]
    public int OrdersCount { get; set; }

    public User User { get; set; } = null!;
}