using MojeAuto.Services.Database;

namespace MojeAuto.Services.Helpers
{
    public static class Seeder
    {
        private static byte[] LoadImage(string relativePath)
        {
            var fullPath = Path.Combine(AppContext.BaseDirectory, relativePath);
            if (!File.Exists(fullPath))
            {
                Console.WriteLine($"Image not found: {fullPath}");
                return Array.Empty<byte>();
            }

            var bytes = File.ReadAllBytes(fullPath);
            Console.WriteLine($"Loaded {bytes.Length} bytes from {relativePath}");
            return bytes;
        }

        public static void Seed(MojeAutoContext db)
        {
            if (!db.Countries.Any())
            {
                db.Countries.AddRange(
                    new Country { Name = "Njemačka", ISOCode = "DE" },
                    new Country { Name = "Hrvatska", ISOCode = "HR" },
                    new Country { Name = "SAD", ISOCode = "US" },
                    new Country { Name = "Japan", ISOCode = "JP" },
                    new Country { Name = "Francuska", ISOCode = "FR" },
                    new Country { Name = "Italija", ISOCode = "IT" },
                    new Country { Name = "Španjolska", ISOCode = "ES" },
                    new Country { Name = "Bosna i Hercegovina", ISOCode = "BA" }
                );
                db.SaveChanges();
            }

            if (!db.Categories.Any())
            {
                db.Categories.AddRange(
                    new Category { Name = "Motor" },
                    new Category { Name = "Kočioni sistem" },
                    new Category { Name = "Ovjes i amortizeri" },
                    new Category { Name = "Električni sistem" },
                    new Category { Name = "Karoserija" },
                    new Category { Name = "Unutrašnjost vozila" },
                    new Category { Name = "Ispušni sistem" },
                    new Category { Name = "Sistem hlađenja" },
                    new Category { Name = "Sistem upravljanja" },
                    new Category { Name = "Sistem goriva" },
                    new Category { Name = "Mjenjač" },
                    new Category { Name = "Kvačilo" },
                    new Category { Name = "Pogon" },
                    new Category { Name = "Zračni jastuci i sigurnosni pojasevi" },
                    new Category { Name = "Stakla i retrovizori" },
                    new Category { Name = "Klima uređaj i grijanje" },
                    new Category { Name = "Brisači i perači stakala" },
                    new Category { Name = "Filteri" },
                    new Category { Name = "Remenje i lanci" },
                    new Category { Name = "Alati i dodatna oprema" }
                );

                db.SaveChanges();
            }

            if (!db.UserRoles.Any())
            {
                db.UserRoles.AddRange(
                    new UserRole { Name = "User" },
                    new UserRole { Name = "Admin" }
                );
                db.SaveChanges();
            }

            if (!db.PaymentMethods.Any())
            {
                db.PaymentMethods.AddRange(
                    new PaymentMethod { Name = "Stripe" },
new PaymentMethod { Name = "Plaćanje na licu mjesta" }
                );
                db.SaveChanges();
            }

            if (!db.DeliveryMethods.Any())
            {
                db.DeliveryMethods.AddRange(
                    new DeliveryMethod
                    {
                        Name = "Osobno preuzimanje",
                        Description = "Preuzimanje narudžbe u najbližoj poslovnici"
                    },
                    new DeliveryMethod
                    {
                        Name = "Standardna dostava",
                        Description = "Dostava na vašu adresu"
                    }
                );

                db.SaveChanges();
            }

            if (!db.DeliveryStatuses.Any())
            {
                db.DeliveryStatuses.AddRange(
                    new DeliveryStatus { Name = "U pripremi" },
                    new DeliveryStatus { Name = "Poslano" },
                    new DeliveryStatus { Name = "Dostavljeno" }
                );
                db.SaveChanges();
            }

            if (!db.Manufacturers.Any())
            {
                db.Manufacturers.AddRange(
                    new Manufacturer { Name = "Bosch", CountryId = 1 },
                    new Manufacturer { Name = "Siemens", CountryId = 1 },
                    new Manufacturer { Name = "ZF Friedrichshafen", CountryId = 1 },
                    new Manufacturer { Name = "Hella", CountryId = 1 },
                    new Manufacturer { Name = "Mahle", CountryId = 1 },
                    new Manufacturer { Name = "Rimac Components", CountryId = 2 },
                    new Manufacturer { Name = "Delphi", CountryId = 3 },
                    new Manufacturer { Name = "ACDelco", CountryId = 3 },
                    new Manufacturer { Name = "Denso", CountryId = 4 },
                    new Manufacturer { Name = "NGK", CountryId = 4 },
                    new Manufacturer { Name = "Aisin", CountryId = 4 },
                    new Manufacturer { Name = "Valeo", CountryId = 5 },
                    new Manufacturer { Name = "Sagem", CountryId = 5 },
                    new Manufacturer { Name = "Magneti Marelli", CountryId = 6 },
                    new Manufacturer { Name = "Brembo", CountryId = 6 },
                    new Manufacturer { Name = "Meyle", CountryId = 1 },
                    new Manufacturer { Name = "TRW", CountryId = 1 },
                    new Manufacturer { Name = "FAG", CountryId = 1 },
                    new Manufacturer { Name = "SEAT Components", CountryId = 7 },
                    new Manufacturer { Name = "ASA Auto", CountryId = 8 }
                );

                db.SaveChanges();
            }

            if (!db.OrderStatuses.Any())
            {
                db.OrderStatuses.AddRange(
                    new OrderStatus { Name = "Naručeno" },
                    new OrderStatus { Name = "Plaćeno" },
                    new OrderStatus { Name = "Dovršeno" },
                    new OrderStatus { Name = "Otkazano" }
                );
                db.SaveChanges();
            }

            if (!db.Cars.Any())
            {
                db.Cars.AddRange(
                  new Car { VIN = "1HGCM82633A123456", Brand = "Honda", Model = "Accord", Year = 2005, Fuel = "Benzin", Engine = "3,0", ImageData = LoadImage("SeedImages/a5.jpg") },
                  new Car { VIN = "WVWZZZ1JZXW000123", Brand = "Volkswagen", Model = "Golf 5", Year = 2008, Fuel = "Benzin", Engine = "1,3", ImageData = LoadImage("SeedImages/e46.jpg") },
                  new Car { VIN = "WDBUF70J34A123456", Brand = "Mercedes-Benz", Model = "E klasa", Year = 2004, Fuel = "Benzin", Engine = "1,5" },
                  new Car { VIN = "WAUZZZ8V4FA012345", Brand = "Audi", Model = "A3", Year = 2015, Fuel = "Dizel", Engine = "3,8", ImageData = LoadImage("SeedImages/e46.jpg") },
                  new Car { VIN = "3FAHP0HA2AR123456", Brand = "Ford", Model = "Fusion", Year = 2010, Fuel = "Benzin", Engine = "2,5" },
                  new Car { VIN = "KMHE34L18GA123456", Brand = "Hyundai", Model = "Sonata", Year = 2016, Fuel = "Dizel", Engine = "2,2", ImageData = LoadImage("SeedImages/f80.jpg") },
                  new Car { VIN = "JN1CV6APXAM123456", Brand = "Infiniti", Model = "G37", Year = 2011, Fuel = "Benzin", Engine = "2,0" },
                  new Car { VIN = "JH4CL96866C123456", Brand = "Acura", Model = "TSX", Year = 2006, Fuel = "Benzin", Engine = "4,0" },
                  new Car { VIN = "1FTFW1ET1EK123456", Brand = "Ford", Model = "F-150", Year = 2014, Fuel = "Dizel", Engine = "1,9", ImageData = LoadImage("SeedImages/f80.jpg") },
                  new Car { VIN = "ZFAAXX00C0P123456", Brand = "Fiat", Model = "Punto", Year = 2009, Fuel = "Dizel", Engine = "1,2", ImageData = LoadImage("SeedImages/a5.jpg") },
                  new Car { VIN = "WVWZZZ3BZWE123456", Brand = "Volkswagen", Model = "Passat B5", Year = 2002, Fuel = "Benzin", Engine = "1,8" },
                  new Car { VIN = "VF1BG1J0H56312345", Brand = "Renault", Model = "Laguna", Year = 2011, Fuel = "Dizel", Engine = "1,6", ImageData = LoadImage("SeedImages/e46.jpg") },
                  new Car { VIN = "TRUZZZ8N021234567", Brand = "Audi", Model = "TT", Year = 2003, Fuel = "Benzin", Engine = "3,2" },
                  new Car { VIN = "YS3DF78K2X7123456", Brand = "Saab", Model = "9-3", Year = 2001, Fuel = "Benzin", Engine = "2,0", ImageData = LoadImage("SeedImages/e46.jpg") },
                  new Car { VIN = "JHMFA16506S123456", Brand = "Honda", Model = "Civic Hybrid", Year = 2006, Fuel = "Hibrid", Engine = "1,3", ImageData = LoadImage("SeedImages/f80.jpg") },
                  new Car { VIN = "2HGFB2F5XCH123456", Brand = "Honda", Model = "Civic", Year = 2012, Fuel = "Benzin", Engine = "1,8" },
                  new Car { VIN = "5NPE24AF9FH123456", Brand = "Hyundai", Model = "Elantra", Year = 2015, Fuel = "Dizel", Engine = "2,0", ImageData = LoadImage("SeedImages/e46.jpg") },
                  new Car { VIN = "3VW2K7AJ5EM123456", Brand = "Volkswagen", Model = "Jetta", Year = 2014, Fuel = "Benzin", Engine = "2,0" },
                  new Car { VIN = "SALTY19484A123456", Brand = "Land Rover", Model = "Discovery", Year = 2004, Fuel = "Dizel", Engine = "2,5", ImageData = LoadImage("SeedImages/f80.jpg") },
                  new Car { VIN = "1C4RJEBG0FC123456", Brand = "Jeep", Model = "Grand Cherokee", Year = 2015, Fuel = "Benzin", Engine = "3,6", ImageData = LoadImage("SeedImages/e46.jpg") }
              );

                db.SaveChanges();
            }

            if (!db.Users.Any())
            {
                db.Users.AddRange(
                    new User { FirstName = "Lejla", LastName = "Softić", Email = "lejla.softic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Zmaja od Bosne 33", PhoneNumber = "062222222", BirthDate = new DateTime(1992, 8, 24), CountryId = 8, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar3.png") },
                    new User { FirstName = "Jasmin", LastName = "Imamović", Email = "jasmin.imamovic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Mejtaš bb", PhoneNumber = "061333333", BirthDate = new DateTime(1988, 11, 30), CountryId = 1, UserRoleId = 1 },
                    new User { FirstName = "Amina", LastName = "Smajić", Email = "amina.smajic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Ferhadija 45", PhoneNumber = "061444444", BirthDate = new DateTime(1997, 2, 14), CountryId = 4, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar1.jpg") },
                    new User { FirstName = "Faruk", LastName = "Mujić", Email = "faruk.mujic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Titova 7", PhoneNumber = "061555555", BirthDate = new DateTime(1994, 9, 3), CountryId = 3, UserRoleId = 1 },
                    new User { FirstName = "Selma", LastName = "Ćosić", Email = "selma.cosic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Obala Kulina bana 23", PhoneNumber = "061666666", BirthDate = new DateTime(1991, 6, 21), CountryId = 5, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar2.jpg") },
                    new User { FirstName = "Haris", LastName = "Omerović", Email = "haris.omerovic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Maršala Tita 88", PhoneNumber = "061777777", BirthDate = new DateTime(1989, 12, 5), CountryId = 2, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar3.png") },
                    new User { FirstName = "Dženita", LastName = "Šabić", Email = "dzenita.sabic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Džemala Bijedića 14", PhoneNumber = "062888888", BirthDate = new DateTime(1993, 3, 8), CountryId = 6, UserRoleId = 1 },
                    new User { FirstName = "Mirza", LastName = "Alić", Email = "mirza.alic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Koševo 18", PhoneNumber = "063999999", BirthDate = new DateTime(1987, 7, 12), CountryId = 8, UserRoleId = 1 },
                    new User { FirstName = "Ajla", LastName = "Hodžić", Email = "ajla.hodzic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Grbavička 3", PhoneNumber = "064101010", BirthDate = new DateTime(1996, 10, 19), CountryId = 1, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar1.jpg") },
                    new User { FirstName = "Tarik", LastName = "Memić", Email = "tarik.memic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Bulevar bb", PhoneNumber = "062202020", BirthDate = new DateTime(1995, 4, 17), CountryId = 7, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar3.png") },
                    new User { FirstName = "Emina", LastName = "Delić", Email = "emina.delic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Šehitluci 29", PhoneNumber = "061303030", BirthDate = new DateTime(1992, 1, 22), CountryId = 6, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar2.jpg") },
                    new User { FirstName = "Adnan", LastName = "Bešić", Email = "adnan.besic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Logavina 40", PhoneNumber = "062404040", BirthDate = new DateTime(1990, 6, 11), CountryId = 4, UserRoleId = 1 },
                    new User { FirstName = "Fatima", LastName = "Suljić", Email = "fatima.suljic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Hrasno bb", PhoneNumber = "061505050", BirthDate = new DateTime(1986, 8, 8), CountryId = 8, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar1.jpg") },
                    new User { FirstName = "Nedim", LastName = "Zulić", Email = "nedim.zulic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Skenderija 6", PhoneNumber = "063606060", BirthDate = new DateTime(1993, 5, 25), CountryId = 1, UserRoleId = 1 },
                    new User { FirstName = "Lamija", LastName = "Halilović", Email = "lamija.halilovic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Vrbanja bb", PhoneNumber = "064707070", BirthDate = new DateTime(1998, 9, 9), CountryId = 5, UserRoleId = 1 },
                    new User { FirstName = "Ismar", LastName = "Selimović", Email = "ismar.selimovic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Bare 44", PhoneNumber = "061808080", BirthDate = new DateTime(1991, 2, 2), CountryId = 2, UserRoleId = 1 },
                    new User { FirstName = "Naida", LastName = "Kadić", Email = "naida.kadic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Otoka 2", PhoneNumber = "062909090", BirthDate = new DateTime(1989, 11, 15), CountryId = 3, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar2.jpg") },
                    new User { FirstName = "Armin", LastName = "Karalić", Email = "armin.karalic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("pass"), Address = "Ilidža 88", PhoneNumber = "061121212", BirthDate = new DateTime(1994, 7, 7), CountryId = 6, UserRoleId = 1, ImageData = LoadImage("SeedImages/avatar1.jpg") },
                    new User { FirstName = "Medina", LastName = "Mehić", Email = "mobile@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"), Address = "Dobrinja bb", PhoneNumber = "062131313", BirthDate = new DateTime(1997, 12, 29), CountryId = 8, UserRoleId = 1 },
                    new User { FirstName = "Nedim", LastName = "Zolj", Email = "desktop@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"), Address = "Vrapčići 72", PhoneNumber = "062614400", BirthDate = new DateTime(2000, 10, 20), CountryId = 8, UserRoleId = 2, ImageData = LoadImage("SeedImages/avatar3.png") }
                );

                db.SaveChanges();
            }

            if (!db.Parts.Any())
            {
                db.Parts.AddRange(
                    new Part { Name = "Zračni filter", CatalogNumber = "AF123", Description = "Filter za zrak motora", Weight = "0,3", Price = 19.99m, WarrantyMonths = 12, Quantity = 100, TotalSold = 20, ManufacturerId = 1, CategoryId = 1, EstimatedArrivalDays = 2, ImageData = LoadImage("SeedImages/part1.jpg") },
                    new Part { Name = "Filter ulja", CatalogNumber = "OF444", Description = "Filter za ulje motora", Weight = "0,4", Price = 12.99m, WarrantyMonths = 12, Quantity = 80, TotalSold = 30, ManufacturerId = 9, CategoryId = 1, EstimatedArrivalDays = 3 },
                    new Part { Name = "Kočione pločice", CatalogNumber = "BP789", Description = "Set kočionih pločica", Weight = "1,2", Price = 45.99m, WarrantyMonths = 18, Quantity = 150, TotalSold = 60, ManufacturerId = 14, CategoryId = 2, EstimatedArrivalDays = 1, ImageData = LoadImage("SeedImages/part2.jpg") },
                    new Part { Name = "Amortizer", CatalogNumber = "SH321", Description = "Prednji amortizer", Weight = "3,1", Price = 79.99m, WarrantyMonths = 24, Quantity = 70, TotalSold = 35, ManufacturerId = 17, CategoryId = 3, EstimatedArrivalDays = 4 },
                    new Part { Name = "Akumulator", CatalogNumber = "BT888", Description = "12V 60Ah akumulator", Weight = "15", Price = 89.99m, WarrantyMonths = 24, Quantity = 40, TotalSold = 10, ManufacturerId = 8, CategoryId = 4, EstimatedArrivalDays = 2, ImageData = LoadImage("SeedImages/part3.jpg") },
                    new Part { Name = "Branik prednji", CatalogNumber = "BM456", Description = "Prednji plastični branik", Weight = "6,5", Price = 129.99m, WarrantyMonths = 12, Quantity = 25, TotalSold = 8, ManufacturerId = 13, CategoryId = 5, EstimatedArrivalDays = 3 },
                    new Part { Name = "Sjedalo vozača", CatalogNumber = "SD777", Description = "Vozačko sjedalo s podešavanjem", Weight = "12", Price = 199.99m, WarrantyMonths = 24, Quantity = 15, TotalSold = 5, ManufacturerId = 19, CategoryId = 6, EstimatedArrivalDays = 5 },
                    new Part { Name = "Ispušna cijev", CatalogNumber = "EX321", Description = "Završni dio ispušnog sistema", Weight = "2,5", Price = 59.99m, WarrantyMonths = 12, Quantity = 50, TotalSold = 18, ManufacturerId = 6, CategoryId = 7, EstimatedArrivalDays = 1, ImageData = LoadImage("SeedImages/part1.jpg") },
                    new Part { Name = "Ventilator hladnjaka", CatalogNumber = "RF232", Description = "Ventilator za hlađenje motora", Weight = "3", Price = 74.99m, WarrantyMonths = 18, Quantity = 30, TotalSold = 12, ManufacturerId = 4, CategoryId = 8, EstimatedArrivalDays = 3 },
                    new Part { Name = "Volan", CatalogNumber = "ST555", Description = "Kožni volan sa komandama", Weight = "1,7", Price = 110.00m, WarrantyMonths = 24, Quantity = 20, TotalSold = 7, ManufacturerId = 10, CategoryId = 9, EstimatedArrivalDays = 2, ImageData = LoadImage("SeedImages/part2.jpg") },
                    new Part { Name = "Pumpa goriva", CatalogNumber = "FP898", Description = "Električna pumpa goriva", Weight = "1,1", Price = 65.00m, WarrantyMonths = 12, Quantity = 45, TotalSold = 20, ManufacturerId = 12, CategoryId = 10, EstimatedArrivalDays = 2 },
                    new Part { Name = "Mjenjač 5 brzina", CatalogNumber = "TR789", Description = "Manualni mjenjač", Weight = "20", Price = 399.99m, WarrantyMonths = 36, Quantity = 10, TotalSold = 2, ManufacturerId = 1, CategoryId = 11, EstimatedArrivalDays = 4, ImageData = LoadImage("SeedImages/part3.jpg") },
                    new Part { Name = "Set kvačila", CatalogNumber = "CL333", Description = "Kompletan set kvačila", Weight = "4,5", Price = 149.99m, WarrantyMonths = 24, Quantity = 35, TotalSold = 17, ManufacturerId = 15, CategoryId = 12, EstimatedArrivalDays = 1 },
                    new Part { Name = "Pogonska osovina", CatalogNumber = "AX456", Description = "Prednja pogonska osovina", Weight = "6,0", Price = 89.99m, WarrantyMonths = 18, Quantity = 22, TotalSold = 9, ManufacturerId = 18, CategoryId = 13, EstimatedArrivalDays = 3 },
                    new Part { Name = "Zračni jastuk", CatalogNumber = "AB777", Description = "Vozačev zračni jastuk", Weight = "2,3", Price = 210.00m, WarrantyMonths = 36, Quantity = 12, TotalSold = 3, ManufacturerId = 2, CategoryId = 14, EstimatedArrivalDays = 5, ImageData = LoadImage("SeedImages/part1.jpg") },
                    new Part { Name = "Retrovizor lijevi", CatalogNumber = "MR111", Description = "Električni retrovizor s grijanjem", Weight = "1,1", Price = 45.50m, WarrantyMonths = 12, Quantity = 60, TotalSold = 21, ManufacturerId = 16, CategoryId = 15, EstimatedArrivalDays = 2 },
                    new Part { Name = "Komplet klima uređaja", CatalogNumber = "AC999", Description = "Sistem klimatizacije", Weight = "8,5", Price = 299.99m, WarrantyMonths = 24, Quantity = 8, TotalSold = 4, ManufacturerId = 11, CategoryId = 16, EstimatedArrivalDays = 4, ImageData = LoadImage("SeedImages/part2.jpg") },
                    new Part { Name = "Motor brisača", CatalogNumber = "WM555", Description = "Prednji motor brisača", Weight = "1,6", Price = 69.00m, WarrantyMonths = 18, Quantity = 32, TotalSold = 11, ManufacturerId = 5, CategoryId = 17, EstimatedArrivalDays = 2 },
                    new Part { Name = "Filter kabine", CatalogNumber = "CF654", Description = "Filter zraka za kabinu", Weight = "0,2", Price = 14.99m, WarrantyMonths = 12, Quantity = 120, TotalSold = 40, ManufacturerId = 7, CategoryId = 18, EstimatedArrivalDays = 1, ImageData = LoadImage("SeedImages/part3.jpg") },
                    new Part { Name = "Zupčasti remen", CatalogNumber = "TB123", Description = "Remen razvoda", Weight = "0,8", Price = 34.99m, WarrantyMonths = 12, Quantity = 75, TotalSold = 25, ManufacturerId = 3, CategoryId = 19, EstimatedArrivalDays = 2 },
                    new Part { Name = "Pumpa za vodu", CatalogNumber = "WP010", Description = "Pumpa za hlađenje motora", Weight = "1,5", Price = 42.99m, WarrantyMonths = 12, Quantity = 60, TotalSold = 22, ManufacturerId = 9, CategoryId = 8, EstimatedArrivalDays = 2, ImageData = LoadImage("SeedImages/part1.jpg") },
new Part { Name = "Kočione pločice", CatalogNumber = "BP220", Description = "Set prednjih kočionih pločica", Weight = "1,5", Price = 34.50m, WarrantyMonths = 18, Quantity = 80, TotalSold = 40, ManufacturerId = 14, CategoryId = 2, EstimatedArrivalDays = 3 },
new Part { Name = "Set kvačila", CatalogNumber = "CL320", Description = "Kompletan set kvačila", Weight = "4,2", Price = 159.99m, WarrantyMonths = 24, Quantity = 30, TotalSold = 12, ManufacturerId = 13, CategoryId = 12, EstimatedArrivalDays = 4, ImageData = LoadImage("SeedImages/part2.jpg") },
new Part { Name = "Amortizer", CatalogNumber = "SH110", Description = "Prednji lijevi amortizer", Weight = "3,5", Price = 79.00m, WarrantyMonths = 18, Quantity = 45, TotalSold = 15, ManufacturerId = 3, CategoryId = 3, EstimatedArrivalDays = 1 },
new Part { Name = "Ulje za motor", CatalogNumber = "EO555", Description = "Sintetičko ulje 5W-40", Weight = "4", Price = 49.90m, WarrantyMonths = 12, Quantity = 70, TotalSold = 35, ManufacturerId = 6, CategoryId = 1, EstimatedArrivalDays = 5, ImageData = LoadImage("SeedImages/part3.jpg") },
new Part { Name = "Disk kočnice", CatalogNumber = "BD770", Description = "Ventilirani disk kočnice", Weight = "6,2", Price = 65.50m, WarrantyMonths = 24, Quantity = 50, TotalSold = 27, ManufacturerId = 15, CategoryId = 2, EstimatedArrivalDays = 2 },
new Part { Name = "Kompresor klime", CatalogNumber = "AC890", Description = "Kompresor klima uređaja", Weight = "7,3", Price = 210.00m, WarrantyMonths = 24, Quantity = 25, TotalSold = 8, ManufacturerId = 12, CategoryId = 16, EstimatedArrivalDays = 3, ImageData = LoadImage("SeedImages/part1.jpg") },
new Part { Name = "Lambda sonda", CatalogNumber = "LS999", Description = "Senzor kisika za ispušni sistem", Weight = "0,6", Price = 69.00m, WarrantyMonths = 12, Quantity = 40, TotalSold = 14, ManufacturerId = 8, CategoryId = 7, EstimatedArrivalDays = 1 },
new Part { Name = "Brisači", CatalogNumber = "WS100", Description = "Set prednjih brisača", Weight = "0,9", Price = 22.90m, WarrantyMonths = 12, Quantity = 90, TotalSold = 38, ManufacturerId = 18, CategoryId = 17, EstimatedArrivalDays = 2, ImageData = LoadImage("SeedImages/part2.jpg") },
new Part { Name = "Alternator", CatalogNumber = "ALT333", Description = "Generator električne energije", Weight = "5,7", Price = 135.00m, WarrantyMonths = 24, Quantity = 20, TotalSold = 11, ManufacturerId = 2, CategoryId = 4, EstimatedArrivalDays = 4 }

                );

                db.SaveChanges();
            }

            if (!db.PartCars.Any())
            {
                db.PartCars.AddRange(
                   new PartCar { PartId = 1, CarId = 1 },
new PartCar { PartId = 2, CarId = 1 },
new PartCar { PartId = 3, CarId = 2 },
new PartCar { PartId = 4, CarId = 3 },
new PartCar { PartId = 5, CarId = 4 },
new PartCar { PartId = 6, CarId = 4 },
new PartCar { PartId = 7, CarId = 5 },
new PartCar { PartId = 8, CarId = 6 },
new PartCar { PartId = 9, CarId = 7 },
new PartCar { PartId = 10, CarId = 8 },
new PartCar { PartId = 11, CarId = 9 },
new PartCar { PartId = 12, CarId = 9 },
new PartCar { PartId = 13, CarId = 10 },
new PartCar { PartId = 14, CarId = 11 },
new PartCar { PartId = 15, CarId = 12 },
new PartCar { PartId = 16, CarId = 13 },
new PartCar { PartId = 17, CarId = 14 },
new PartCar { PartId = 18, CarId = 15 },
new PartCar { PartId = 19, CarId = 16 },
new PartCar { PartId = 20, CarId = 17 },
new PartCar { PartId = 1, CarId = 5 },
new PartCar { PartId = 2, CarId = 6 },
new PartCar { PartId = 3, CarId = 7 },
new PartCar { PartId = 4, CarId = 8 },
new PartCar { PartId = 5, CarId = 9 },
new PartCar { PartId = 6, CarId = 10 },
new PartCar { PartId = 7, CarId = 11 },
new PartCar { PartId = 8, CarId = 12 },
new PartCar { PartId = 9, CarId = 13 },
new PartCar { PartId = 10, CarId = 14 },
new PartCar { PartId = 11, CarId = 15 },
new PartCar { PartId = 12, CarId = 16 },
new PartCar { PartId = 13, CarId = 17 },
new PartCar { PartId = 14, CarId = 18 },
new PartCar { PartId = 15, CarId = 19 },
new PartCar { PartId = 16, CarId = 20 },
new PartCar { PartId = 17, CarId = 1 },
new PartCar { PartId = 18, CarId = 2 },
new PartCar { PartId = 19, CarId = 3 },
new PartCar { PartId = 20, CarId = 4 },
new PartCar { PartId = 1, CarId = 10 },
new PartCar { PartId = 2, CarId = 11 },
new PartCar { PartId = 3, CarId = 12 },
new PartCar { PartId = 4, CarId = 13 },
new PartCar { PartId = 5, CarId = 14 },
new PartCar { PartId = 6, CarId = 15 },
new PartCar { PartId = 7, CarId = 16 },
new PartCar { PartId = 8, CarId = 17 },
new PartCar { PartId = 9, CarId = 18 },
new PartCar { PartId = 10, CarId = 19 },
new PartCar { PartId = 11, CarId = 20 },
new PartCar { PartId = 12, CarId = 1 },
new PartCar { PartId = 13, CarId = 2 },
new PartCar { PartId = 14, CarId = 3 },
new PartCar { PartId = 15, CarId = 4 },
new PartCar { PartId = 16, CarId = 5 },
new PartCar { PartId = 17, CarId = 6 },
new PartCar { PartId = 18, CarId = 7 },
new PartCar { PartId = 19, CarId = 8 },
new PartCar { PartId = 20, CarId = 9 }

                );

                db.SaveChanges();
            }

            if (!db.Orders.Any())
            {
                var random = new Random();
                var users = db.Users.ToList();
                var parts = db.Parts.ToList();
                var deliveryMethods = db.DeliveryMethods.ToList();
                var deliveryStatuses = db.DeliveryStatuses.ToList();
                var paymentMethods = db.PaymentMethods.ToList();
                var orderStatuses = db.OrderStatuses.ToList();

                var ordersToAdd = new List<Order>();
                var deliveriesToAdd = new List<Delivery>();

                for (int i = 0; i < 30; i++)
                {
                    var user = users[random.Next(users.Count)];
                    var payment = paymentMethods[random.Next(paymentMethods.Count)];
                    var validStatuses = orderStatuses.Where(s => s.OrderStatusId != 3).ToList();
                    var status = validStatuses[random.Next(validStatuses.Count)];
                    var deliveryStatus = deliveryStatuses[random.Next(deliveryStatuses.Count)];
                    var deliveryMethod = deliveryMethods[random.Next(deliveryMethods.Count)];

                    var delivery = new Delivery
                    {
                        DeliveryMethodId = deliveryMethod.DeliveryMethodId,
                        DeliveryStatusId = deliveryStatus.DeliveryStatusId,
                        DeliveryDate = DateTime.Now.AddDays(-random.Next(1, 10))
                    };

                    deliveriesToAdd.Add(delivery);

                    var orderItems = new List<OrderItem>();
                    int numberOfItems = random.Next(1, 4);

                    for (int j = 0; j < numberOfItems; j++)
                    {
                        var itemPart = parts[random.Next(parts.Count)];
                        var itemQuantity = random.Next(1, 5);

                        orderItems.Add(new OrderItem
                        {
                            PartId = itemPart.PartId,
                            Quantity = itemQuantity,
                            UnitPrice = itemPart.Price
                        });
                    }

                    var order = new Order
                    {
                        UserId = user.UserId,
                        OrderDate = DateTime.Now.AddDays(-random.Next(1, 10)),
                        PaymentMethodId = payment.PaymentMethodId,
                        OrderStatusId = status.OrderStatusId,
                        Delivery = delivery,
                        TotalAmount = orderItems.Sum(oi => oi.UnitPrice * oi.Quantity),
                        OrderItems = orderItems
                    };

                    ordersToAdd.Add(order);
                }

                db.Deliveries.AddRange(deliveriesToAdd);
                db.Orders.AddRange(ordersToAdd);
                db.SaveChanges();
            }
        }
    }
}