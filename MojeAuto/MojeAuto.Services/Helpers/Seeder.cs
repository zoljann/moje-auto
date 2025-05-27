using MojeAuto.Services.Database;


namespace MojeAuto.Services.Helpers
{
    public static class Seeder
    {
        public static void Seed(MojeAutoContext db)
        {
            if (!db.Categories.Any())
            {
                db.Categories.AddRange(
                    new Category { Name = "Motor" },
                    new Category { Name = "Kočioni sistem" },
                    new Category { Name = "Ovjes" }
                );
            }

            db.SaveChanges();
        }
    }
}
