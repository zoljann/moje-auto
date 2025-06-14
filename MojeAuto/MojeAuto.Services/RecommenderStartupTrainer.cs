using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace MojeAuto.Services
{
    public class RecommenderStartupTrainer : IHostedService
    {
        private readonly IServiceProvider _serviceProvider;

        public RecommenderStartupTrainer(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var service = scope.ServiceProvider.GetRequiredService<RecommenderService>();
            await service.TrainModelAsync();
        }

        public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
    }
}