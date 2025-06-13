using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using MojeAuto.Services.Database;
using MojeAuto.Services.RabbitMq.Messages;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace MojeAuto.Consumer
{
    public class AvailabilityConsumer : BackgroundService
    {
        private readonly MailService _mailService;
        private IConnection? _connection;
        private IModel? _channel;
        private readonly MojeAutoContext _context;

        public AvailabilityConsumer(MailService mailService, MojeAutoContext context)
        {
            _mailService = mailService;
            _context = context;
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var factory = new ConnectionFactory
            {
                HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
                Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest"
            };

            _connection = factory.CreateConnection();
            _channel = _connection.CreateModel();
            _channel.QueueDeclare(queue: "part-available", durable: false, exclusive: false, autoDelete: false);

            var consumer = new EventingBasicConsumer(_channel);
            consumer.Received += (model, ea) =>
            {
                try
                {
                    var json = Encoding.UTF8.GetString(ea.Body.ToArray());
                    var message = JsonSerializer.Deserialize<NotifyAvailabilityMessage>(json);

                    Console.WriteLine($"Received notification for PartId: {message?.PartId}, UserId: {message?.UserId}");

                    if (message != null && message.UserId > 0)
                    {
                        var user = _context.Users.FirstOrDefault(u => u.UserId == message.UserId);
                        var part = _context.Parts.FirstOrDefault(p => p.PartId == message.PartId);

                        if (user is not null && !string.IsNullOrEmpty(user.Email) && part is not null)
                        {
                            var subject = "Dio koji ste tražili je sada dostupan!";

                            var body = $"""
Poštovani {user.FirstName},

Obavještavamo vas da je sljedeći dio ponovno dostupan na našoj webstranici - MojeAuto:

Naziv dijela: {part.Name}
Kataloški broj: {part.CatalogNumber}
Cijena: {part.Price:F2} KM

Možete ga odmah pogledati i naručiti putem naše stranice.

Srdačan pozdrav,
MojeAuto tim
""";

                            _mailService.Send(user.Email, subject, body);
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error processing message: {ex.Message}");
                }
            };

            _channel.BasicConsume(queue: "part-available", autoAck: true, consumer: consumer);

            return Task.CompletedTask;
        }

        public override void Dispose()
        {
            _channel?.Close();
            _connection?.Close();
            base.Dispose();
        }
    }
}