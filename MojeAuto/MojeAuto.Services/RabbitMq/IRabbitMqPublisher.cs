namespace MojeAuto.Services.RabbitMq
{
    public interface IRabbitMqPublisher
    {
        void Publish<T>(T message, string queueName);
    }
}