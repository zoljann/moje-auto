using Microsoft.EntityFrameworkCore;
using MojeAuto.Model;
using MojeAuto.Model.Common;

namespace MojeAuto.Services.Database
{
    public class MojeAutoContext : DbContext
    {
        public MojeAutoContext(DbContextOptions<MojeAutoContext> options) : base(options)
        {
        }

        public DbSet<RefreshToken> RefreshTokens { get; set; }
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
        public DbSet<AdminReport> AdminReports { get; set; }
        public DbSet<Manufacturer> Manufacturers { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Country> Countries { get; set; }
        public DbSet<PartAvailabilitySubscription> PartAvailabilitySubscriptions { get; set; }
        public DbSet<PartRecommendation> PartRecommendations { get; set; }
        public DbSet<InitialRecommendation> InitialRecommendations { get; set; }
        public DbSet<RezervacijaProstora> RezervacijaProstora { get; set; }
        public DbSet<RadniProstor> RadniProstor { get; set; }
        public DbSet<KategorijaTransakcije25062025> KategorijaTransakcije25062025 { get; set; }
        public DbSet<Transakcija25062025> Transakcija25062025 { get; set; }
        public DbSet<FinancijskiLimit25062025> FinancijskiLimit25062025 { get; set; }
        public DbSet<TransakcijaLog25062025> TransakcijaLog25062025 { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<Car>()
                .HasIndex(c => c.VIN)
                .IsUnique();

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
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PartCar>()
                .HasIndex(pc => new { pc.CarId, pc.PartId })
                .IsUnique();

            modelBuilder.Entity<Order>()
                .Property(o => o.TotalAmount)
                .HasPrecision(10, 2);

            modelBuilder.Entity<OrderItem>()
                .Property(oi => oi.UnitPrice)
                .HasPrecision(10, 2);

            modelBuilder.Entity<Part>()
                .Property(p => p.Price)
                .HasPrecision(10, 2);

            modelBuilder.Entity<AdminReport>()
                .Property(r => r.TotalSpent)
                .HasPrecision(10, 2);

            modelBuilder.Entity<Order>()
                .HasOne(o => o.Delivery)
                .WithOne()
                .HasForeignKey<Order>(o => o.DeliveryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PartRecommendation>()
    .HasKey(x => new { x.PartId, x.RecommendedPartId });

            modelBuilder.Entity<PartRecommendation>()
                .HasOne(x => x.Part)
                .WithMany()
                .HasForeignKey(x => x.PartId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PartRecommendation>()
                .HasOne(x => x.RecommendedPart)
                .WithMany()
                .HasForeignKey(x => x.RecommendedPartId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<InitialRecommendation>()
    .HasOne(x => x.Part)
    .WithMany()
    .HasForeignKey(x => x.PartId)
    .OnDelete(DeleteBehavior.Restrict);

            base.OnModelCreating(modelBuilder);
        }
    }
}