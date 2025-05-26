using Microsoft.EntityFrameworkCore;

namespace MojeAuto.Services.Database
{
    public class MojeAutoContext : DbContext
    {
        public MojeAutoContext(DbContextOptions<MojeAutoContext> options) : base(options)
        {
        }

        public DbSet<Car> Cars { get; set; }
        public DbSet<Part> Parts { get; set; }
        public DbSet<PartCar> PartCars { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<PaymentMethod> PaymentMethods { get; set; }
        public DbSet<OrderStatus> OrderStatuses { get; set; }
        public DbSet<Delivery> Deliveries { get; set; }
        public DbSet<DeliveryMethod> DeliveryMethods { get; set; }
        public DbSet<DeliveryStatus> DeliveryStatuses { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<AdminReport> AdminReports { get; set; }
        public DbSet<Manufacturer> Manufacturers { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Country> Countries { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Order)
                .WithMany(o => o.OrderItems)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Part)
                .WithMany(p => p.OrderItems)
                .HasForeignKey(oi => oi.PartId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Order>()
                .HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Delivery>()
                .HasOne(d => d.Order)
                .WithOne(o => o.Delivery)
                .HasForeignKey<Delivery>(d => d.OrderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Part>()
                .HasOne(p => p.Manufacturer)
                .WithMany(m => m.Parts)
                .HasForeignKey(p => p.ManufacturerId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Part>()
                .HasOne(p => p.Category)
                .WithMany(c => c.Parts)
                .HasForeignKey(p => p.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PartCar>()
                .HasOne(pc => pc.Part)
                .WithMany(p => p.CompatibleCars)
                .HasForeignKey(pc => pc.PartId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PartCar>()
                .HasOne(pc => pc.Car)
                .WithMany(c => c.CompatibleParts)
                .HasForeignKey(pc => pc.CarId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Notification>()
                .HasOne(n => n.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<AdminReport>()
                .HasOne(ar => ar.User)
                .WithMany(u => u.AdminReports)
                .HasForeignKey(ar => ar.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            base.OnModelCreating(modelBuilder);
        }
    }
}
