using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace MojeAuto.Services.RabbitMq
{
    public class RabbitMqPublisher : IRabbitMqPublisher
    {
        private readonly IConnection _connection;

        public RabbitMqPublisher(IConfiguration configuration)
        {
            var host = configuration["RABBITMQ_HOST"] ?? "localhost";
            var port = int.TryParse(configuration["RABBITMQ_PORT"], out var parsedPort) ? parsedPort : 5672;
            var username = configuration["RABBITMQ_USERNAME"] ?? "guest";
            var password = configuration["RABBITMQ_PASSWORD"] ?? "guest";

            var factory = new RabbitMQ.Client.ConnectionFactory
            {
                HostName = host,
                Port = port,
                UserName = username,
                Password = password
            };

            _connection = factory.CreateConnection();
        }

        public void Publish<T>(T message, string queueName)
        {
            using var channel = _connection.CreateModel();
            channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false);
            var json = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(json);
            channel.BasicPublish(exchange: "", routingKey: queueName, body: body);
        }
    }
}