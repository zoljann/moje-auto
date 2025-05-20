using Microsoft.EntityFrameworkCore;

namespace MojeAuto.Database
{
    public class MojeAutoContext : DbContext
    {
        public MojeAutoContext(DbContextOptions<MojeAutoContext> options) : base(options)
        {
        }

        public DbSet<Car> Car { get; set; }
    }
}
