using Microsoft.EntityFrameworkCore;
using MojeAuto.MojeAuto.Services.Database;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<MojeAutoContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MojeAutoConnection")));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
