using MojeAuto.Services.Database;

namespace MojeAuto.Services.Helpers
{
    public static class Seeder
    {
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
                    new Country { Name = "Španjolska", ISOCode = "ES" }
                );
                db.SaveChanges();
            }

            if (!db.Categories.Any())
            {
                db.Categories.AddRange(
                    new Category { Name = "Motor" },
                    new Category { Name = "Kočioni sustav" },
                    new Category { Name = "Ovjes" },
                    new Category { Name = "Elektrika" },
                    new Category { Name = "Karoserija" },
                    new Category { Name = "Unutrašnjost" }
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
                    new PaymentMethod { Name = "Pouzećem" }
                );
                db.SaveChanges();
            }

            if (!db.DeliveryMethods.Any())
            {
                db.DeliveryMethods.AddRange(
                    new DeliveryMethod
                    {
                        Name = "Standardna dostava",
                        Description = "Dostava u roku od 3-5 radnih dana"
                    },
                    new DeliveryMethod
                    {
                        Name = "Ekspresna dostava",
                        Description = "Dostava u roku od 1-2 radna dana"
                    },
                    new DeliveryMethod
                    {
                        Name = "Osobno preuzimanje",
                        Description = "Preuzimanje narudžbe u najbližoj poslovnici"
                    },
                    new DeliveryMethod
                    {
                        Name = "Dostava istog dana",
                        Description = "Dostava istog dana (dostupno u većim gradovima)"
                    },
                    new DeliveryMethod
                    {
                        Name = "Međunarodna dostava",
                        Description = "Dostava u inozemstvo (7-14 radnih dana)"
                    }
                );
                db.SaveChanges();
            }

            if (!db.DeliveryStatuses.Any())
            {
                db.DeliveryStatuses.AddRange(
                    new DeliveryStatus { Name = "U obradi" },
                    new DeliveryStatus { Name = "Poslano" },
                    new DeliveryStatus { Name = "U transportu" },
                    new DeliveryStatus { Name = "U dostavi" },
                    new DeliveryStatus { Name = "Dostavljeno" },
                    new DeliveryStatus { Name = "Vraćeno" },
                    new DeliveryStatus { Name = "Otkazano" }
                );
                db.SaveChanges();
            }

            if (!db.Manufacturers.Any())
            {
                db.Manufacturers.AddRange(
                    new Manufacturer { Name = "Bosch", CountryId = 1 },
                    new Manufacturer { Name = "Siemens", CountryId = 1 },
                    new Manufacturer { Name = "Denso", CountryId = 4 },
                    new Manufacturer { Name = "Valeo", CountryId = 5 },
                    new Manufacturer { Name = "Magneti Marelli", CountryId = 6 },
                    new Manufacturer { Name = "ZF Friedrichshafen", CountryId = 1 }
                );
                db.SaveChanges();
            }

            if (!db.OrderStatuses.Any())
            {
                db.OrderStatuses.AddRange(
                    new OrderStatus { Name = "Na čekanju" },
                    new OrderStatus { Name = "U obradi" },
                    new OrderStatus { Name = "Plaćeno" },
                    new OrderStatus { Name = "Poslano" },
                    new OrderStatus { Name = "Dovršeno" },
                    new OrderStatus { Name = "Otkazano" },
                    new OrderStatus { Name = "Povrat novca" }
                );
                db.SaveChanges();
            }

            if (!db.Cars.Any())
            {
                db.Cars.AddRange(
                    new Car { VIN = "1HGCM82633A123456", Brand = "Honda", Model = "Accord", Year = 2005, Fuel = "Benzin", Engine = "3.0" },
                    new Car { VIN = "WVWZZZ1JZXW000123", Brand = "Volkswagen", Model = "Golf 5", Year = 2008, Fuel = "Benzin", Engine = "1.3" },
                    new Car { VIN = "WDBUF70J34A123456", Brand = "Mercedes-Benz", Model = "E klasa", Year = 2004, Fuel = "Benzin", Engine = "1.5" },
                    new Car { VIN = "WAUZZZ8V4FA012345", Brand = "Audi", Model = "A3", Year = 2015, Fuel = "Dizel", Engine = "3.8" },
                    new Car { VIN = "3FAHP0HA2AR123456", Brand = "Ford", Model = "Fusion", Year = 2010, Fuel = "Benzin", Engine = "2.5" },
                    new Car { VIN = "KMHE34L18GA123456", Brand = "Hyundai", Model = "Sonata", Year = 2016, Fuel = "Dizel", Engine = "2.2" },
                    new Car { VIN = "JN1CV6APXAM123456", Brand = "Infiniti", Model = "G37", Year = 2011, Fuel = "Benzin", Engine = "2.0" },
                    new Car { VIN = "JH4CL96866C123456", Brand = "Acura", Model = "TSX", Year = 2006, Fuel = "Benzin", Engine = "4.0" },
                    new Car { VIN = "1FTFW1ET1EK123456", Brand = "Ford", Model = "F-150", Year = 2014, Fuel = "Dizel", Engine = "1.9" },
                    new Car { VIN = "ZFAAXX00C0P123456", Brand = "Fiat", Model = "Punto", Year = 2009, Fuel = "Dizel", Engine = "1.2" }
                );
                db.SaveChanges();
            }

            var userRoleUser = db.UserRoles.First(ur => ur.Name == "user");
            var userRoleAdmin = db.UserRoles.First(ur => ur.Name == "Admin");

            var germany = db.Countries.First(c => c.Name == "Hrvatska");
            var croatia = db.Countries.First(c => c.Name == "SAD");
            var usa = db.Countries.First(c => c.Name == "Japan");

            if (!db.Users.Any())
            {
                db.Users.AddRange(
                    new User { FirstName = "Ivan", LastName = "Kovač", Email = "ivan.kovac@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 1", PhoneNumber = "061123456", BirthDate = new DateTime(1995, 1, 15), CountryId = germany.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Marko", LastName = "Marić", Email = "marko.maric@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 2", PhoneNumber = "062223344", BirthDate = new DateTime(1988, 5, 10), CountryId = germany.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Ana", LastName = "Babić", Email = "ana.babic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 3", PhoneNumber = "063334455", BirthDate = new DateTime(1992, 3, 22), CountryId = croatia.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Petar", LastName = "Lukić", Email = "petar.lukic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 4", PhoneNumber = "064445566", BirthDate = new DateTime(1985, 9, 5), CountryId = usa.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Maja", LastName = "Ilić", Email = "maja.ilic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 5", PhoneNumber = "065556677", BirthDate = new DateTime(1990, 7, 18), CountryId = croatia.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Nikola", LastName = "Pavić", Email = "nikola.pavic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 6", PhoneNumber = "066667788", BirthDate = new DateTime(1993, 11, 2), CountryId = germany.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Ivana", LastName = "Jurić", Email = "ivana.juric@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 7", PhoneNumber = "067778899", BirthDate = new DateTime(1996, 4, 8), CountryId = germany.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Tomislav", LastName = "Šimić", Email = "tomislav.simic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 8", PhoneNumber = "068889900", BirthDate = new DateTime(1987, 6, 29), CountryId = usa.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Lana", LastName = "Perić", Email = "lana.peric@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 9", PhoneNumber = "069990011", BirthDate = new DateTime(1998, 2, 17), CountryId = croatia.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Dario", LastName = "Matić", Email = "dario.matic@example.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("randomPassword"), Address = "Ulica 10", PhoneNumber = "060112233", BirthDate = new DateTime(1989, 12, 12), CountryId = germany.CountryId, UserRoleId = userRoleUser.UserRoleId },
                    new User { FirstName = "Nedim", LastName = "Zolj", Email = "desktop@gmail.com", PasswordHash = BCrypt.Net.BCrypt.HashPassword("test"), Address = "Ulica 10", PhoneNumber = "060112233", BirthDate = new DateTime(1989, 12, 12), CountryId = germany.CountryId, UserRoleId = userRoleAdmin.UserRoleId }
                );
                db.SaveChanges();
            }

            var bosch = db.Manufacturers.First(m => m.Name == "Bosch");
            var siemens = db.Manufacturers.First(m => m.Name == "Siemens");
            var denso = db.Manufacturers.First(m => m.Name == "Denso");

            var motorCategory = db.Categories.First(c => c.Name == "Motor");
            var kocioniCategory = db.Categories.First(c => c.Name == "Elektrika");
            var ovjesCategory = db.Categories.First(c => c.Name == "Ovjes");

            if (!db.Parts.Any())
            {
                db.Parts.AddRange(
                    new Part { Name = "Zračni filter", CatalogNumber = "AF123", Description = "Filter za zrak motora", Weight = "0.3kg", Price = 19.99m, WarrantyMonths = 12, Quantity = 100, TotalSold = 20, ManufacturerId = bosch.CountryId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 2 },
                    new Part { Name = "Kočione pločice", CatalogNumber = "BP456", Description = "Prednje pločice za kočnice", Weight = "1.5kg", Price = 45.50m, WarrantyMonths = 24, Quantity = 50, TotalSold = 15, ManufacturerId = siemens.CountryId, CategoryId = kocioniCategory.CategoryId, EstimatedArrivalDays = 3 },
                    new Part { Name = "Amortizer", CatalogNumber = "SH789", Description = "Stražnji amortizer", Weight = "2.1kg", Price = 89.99m, WarrantyMonths = 24, Quantity = 30, TotalSold = 5, ManufacturerId = bosch.CountryId, CategoryId = ovjesCategory.CategoryId, EstimatedArrivalDays = 4 },
                    new Part { Name = "Set kvačila", CatalogNumber = "CL111", Description = "Komplet kvačila za VW Golf", Weight = "5kg", Price = 220.00m, WarrantyMonths = 18, Quantity = 25, TotalSold = 8, ManufacturerId = denso.CountryId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 5 },
                    new Part { Name = "Ulje za motor", CatalogNumber = "OL555", Description = "5W-40 sintetičko ulje", Weight = "4kg", Price = 35.00m, WarrantyMonths = 6, Quantity = 200, TotalSold = 75, ManufacturerId = denso.CountryId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 1 },
                    new Part { Name = "Pumpa za vodu", CatalogNumber = "WP222", Description = "Pumpa rashladnog sistema", Weight = "1.2kg", Price = 65.75m, WarrantyMonths = 24, Quantity = 40, TotalSold = 10, ManufacturerId = siemens.CountryId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 3 },
                    new Part { Name = "Disk kočnice", CatalogNumber = "BD333", Description = "Prednji disk kočnice", Weight = "3.0kg", Price = 75.99m, WarrantyMonths = 24, Quantity = 35, TotalSold = 7, ManufacturerId = bosch.CountryId, CategoryId = kocioniCategory.CategoryId, EstimatedArrivalDays = 4 },
                    new Part { Name = "Filter ulja", CatalogNumber = "OF444", Description = "Filter za ulje motora", Weight = "0.4kg", Price = 12.99m, WarrantyMonths = 12, Quantity = 80, TotalSold = 30, ManufacturerId = denso.CountryId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 2 },
                    new Part { Name = "Senzor temperature", CatalogNumber = "TS555", Description = "Senzor za temperaturu motora", Weight = "0.2kg", Price = 25.50m, WarrantyMonths = 12, Quantity = 60, TotalSold = 18, ManufacturerId = siemens.ManufacturerId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 2 },
                    new Part { Name = "Filter za gorivo", CatalogNumber = "FF666", Description = "Filter goriva za dizel", Weight = "0.5kg", Price = 29.99m, WarrantyMonths = 12, Quantity = 90, TotalSold = 22, ManufacturerId = bosch.CountryId, CategoryId = motorCategory.CategoryId, EstimatedArrivalDays = 3 }
                );
                db.SaveChanges();
            }

            var partFilter = db.Parts.First(p => p.Name == "Zračni filter");
            var partBrakePads = db.Parts.First(p => p.Name == "Kočione pločice");
            var partShockAbsorber = db.Parts.First(p => p.Name == "Amortizer");
            var partClutchSet = db.Parts.First(p => p.Name == "Set kvačila");
            var partMotorOil = db.Parts.First(p => p.Name == "Ulje za motor");
            var partWaterPump = db.Parts.First(p => p.Name == "Pumpa za vodu");
            var partBrakeDisc = db.Parts.First(p => p.Name == "Disk kočnice");
            var partOilFilter = db.Parts.First(p => p.Name == "Filter ulja");
            var partTempSensor = db.Parts.First(p => p.Name == "Senzor temperature");
            var partFuelFilter = db.Parts.First(p => p.Name == "Filter za gorivo");

            var carHonda = db.Cars.First(c => c.Brand == "Honda" && c.Model == "Accord");
            var carVW = db.Cars.First(c => c.Brand == "Volkswagen" && c.Model == "Golf 5");
            var carMercedes = db.Cars.First(c => c.Brand == "Mercedes-Benz" && c.Model == "E klasa");
            var carAudi = db.Cars.First(c => c.Brand == "Audi" && c.Model == "A3");
            var carFordFusion = db.Cars.First(c => c.Brand == "Ford" && c.Model == "Fusion");
            var carHyundai = db.Cars.First(c => c.Brand == "Hyundai" && c.Model == "Sonata");
            var carInfiniti = db.Cars.First(c => c.Brand == "Infiniti" && c.Model == "G37");
            var carAcura = db.Cars.First(c => c.Brand == "Acura" && c.Model == "TSX");
            var carFordF150 = db.Cars.First(c => c.Brand == "Ford" && c.Model == "F-150");
            var carFiat = db.Cars.First(c => c.Brand == "Fiat" && c.Model == "Punto");

            if (!db.PartCars.Any())
            {
                db.PartCars.AddRange(
                    new PartCar { PartId = partFilter.PartId, CarId = carHonda.CarId },
                    new PartCar { PartId = partFilter.PartId, CarId = carVW.CarId },
                    new PartCar { PartId = partBrakePads.PartId, CarId = carVW.CarId },
                    new PartCar { PartId = partBrakePads.PartId, CarId = carAudi.CarId },
                    new PartCar { PartId = partShockAbsorber.PartId, CarId = carMercedes.CarId },
                    new PartCar { PartId = partClutchSet.PartId, CarId = carVW.CarId },
                    new PartCar { PartId = partMotorOil.PartId, CarId = carFordFusion.CarId },
                    new PartCar { PartId = partWaterPump.PartId, CarId = carHyundai.CarId },
                    new PartCar { PartId = partBrakeDisc.PartId, CarId = carAudi.CarId },
                    new PartCar { PartId = partOilFilter.PartId, CarId = carFordFusion.CarId },
                    new PartCar { PartId = partTempSensor.PartId, CarId = carHyundai.CarId },
                    new PartCar { PartId = partFuelFilter.PartId, CarId = carHonda.CarId },
                    new PartCar { PartId = partFuelFilter.PartId, CarId = carFiat.CarId },
                    new PartCar { PartId = partBrakeDisc.PartId, CarId = carMercedes.CarId },
                    new PartCar { PartId = partShockAbsorber.PartId, CarId = carAcura.CarId },
                    new PartCar { PartId = partClutchSet.PartId, CarId = carFordF150.CarId },
                    new PartCar { PartId = partMotorOil.PartId, CarId = carFiat.CarId },
                    new PartCar { PartId = partWaterPump.PartId, CarId = carInfiniti.CarId },
                    new PartCar { PartId = partOilFilter.PartId, CarId = carAcura.CarId },
                    new PartCar { PartId = partTempSensor.PartId, CarId = carFordF150.CarId }
                );

                db.SaveChanges();
            }

            if (!db.Orders.Any())
            {
                var users = db.Users.Take(10).ToList();
                var paymentMethod = db.PaymentMethods.First();
                var orderStatus = db.OrderStatuses.First();
                var deliveryStatuses = db.DeliveryStatuses.ToList();
                var deliveryMethod = db.DeliveryMethods.First();
                var parts = db.Parts.Take(5).ToList();

                for (int i = 0; i < 10; i++)
                {
                    var delivery = new Delivery
                    {
                        DeliveryMethodId = deliveryMethod.DeliveryMethodId,
                        DeliveryStatusId = deliveryStatuses[i % deliveryStatuses.Count].DeliveryStatusId,
                        DeliveryDate = DateTime.Now.AddDays(-i)
                    };

                    db.Deliveries.Add(delivery);
                    db.SaveChanges();

                    var order = new Order
                    {
                        UserId = users[i].UserId,
                        OrderDate = DateTime.Now.AddDays(-i),
                        TotalAmount = parts[i % parts.Count].Price * 2,
                        PaymentMethodId = paymentMethod.PaymentMethodId,
                        OrderStatusId = orderStatus.OrderStatusId,
                        DeliveryId = delivery.DeliveryId,
                        OrderItems = new List<OrderItem>
            {
                new OrderItem
                {
                    PartId = parts[i % parts.Count].PartId,
                    Quantity = 2,
                    UnitPrice = parts[i % parts.Count].Price
                }
            }
                    };

                    db.Orders.Add(order);
                    db.SaveChanges();
                }
            }
        }
    }
}