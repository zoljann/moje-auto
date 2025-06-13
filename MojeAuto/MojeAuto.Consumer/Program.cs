using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MojeAuto.Consumer;
using MojeAuto.Services.Database;

var envPath = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".env");
if (File.Exists(envPath))
{
    DotNetEnv.Env.Load(envPath);
}

var builder = Host.CreateApplicationBuilder(args);

var connectionString = Environment.GetEnvironmentVariable("MOJEAUTO_CONN")
    ?? throw new Exception("MOJEAUTO_CONN not set");

builder.Services.AddDbContext<MojeAutoContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddTransient<MailService>();
builder.Services.AddHostedService<AvailabilityConsumer>();

var host = builder.Build();
host.Run();