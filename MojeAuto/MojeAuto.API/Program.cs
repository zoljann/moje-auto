using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;
using MojeAuto.Services.Helpers;
using System.Text;

DotNetEnv.Env.Load("../.env");
var builder = WebApplication.CreateBuilder(args);

// JWT config
var jwtSettings = builder.Configuration.GetSection("Jwt");
var keyString = Environment.GetEnvironmentVariable("JWT_KEY") ?? throw new Exception("JWT_KEY not set");
var issuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? throw new Exception("JWT_ISSUER not set");
var audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? throw new Exception("JWT_AUDIENCE not set");

var key = Encoding.UTF8.GetBytes(keyString);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = issuer,
        ValidAudience = audience,
        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
});

// Add services
var connectionString = Environment.GetEnvironmentVariable("MOJEAUTO_CONN")
    ?? throw new Exception("MOJEAUTO_CONN not set");

builder.Services.AddDbContext<MojeAutoContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IBaseCrudService<User, UserSearchRequest, UserInsertRequest, UserUpdateRequest>, UserService>();
builder.Services.AddScoped<IBaseCrudService<Car, CarSearchRequest, CarInsertRequest, CarUpdateRequest>, CarService>();
builder.Services.AddScoped<IBaseCrudService<Category, CategorySearchRequest, CategoryInsertRequest, CategoryUpdateRequest>, CategoryService>();
builder.Services.AddScoped<IBaseCrudService<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest>, PartService>();
builder.Services.AddScoped<IBaseCrudService<Country, CountrySearchRequest, CountryInsertRequest, CountryUpdateRequest>, CountryService>();
builder.Services.AddScoped<IBaseCrudService<DeliveryMethod, DeliveryMethodSearchRequest, DeliveryMethodInsertRequest, DeliveryMethodUpdateRequest>, DeliveryMethodService>();
builder.Services.AddScoped<IBaseCrudService<DeliveryStatus, DeliveryStatusSearchRequest, DeliveryStatusInsertRequest, DeliveryStatusUpdateRequest>, DeliveryStatusService>();
builder.Services.AddScoped<IBaseCrudService<Manufacturer, ManufacturerSearchRequest, ManufacturerInsertRequest, ManufacturerUpdateRequest>, ManufacturerService>();
builder.Services.AddScoped<IBaseCrudService<Notification, NotificationSearchRequest, NotificationInsertRequest, NotificationUpdateRequest>, NotificationService>();
builder.Services.AddScoped<IBaseCrudService<OrderStatus, OrderStatusSearchRequest, OrderStatusInsertRequest, OrderStatusUpdateRequest>, OrderStatusService>();
builder.Services.AddScoped<IBaseCrudService<PartCar, PartCarSearchRequest, PartCarInsertRequest, PartCarUpdateRequest>, PartCarService>();
builder.Services.AddScoped<IBaseCrudService<PaymentMethod, PaymentMethodSearchRequest, PaymentMethodInsertRequest, PaymentMethodUpdateRequest>, PaymentMethodService>();
builder.Services.AddScoped<IBaseCrudService<UserRole, UserRoleSearchRequest, UserRoleInsertRequest, UserRoleUpdateRequest>, UserRoleService>();
builder.Services.AddScoped<IBaseCrudService<Order, OrderSearchRequest, OrderInsertRequest, OrderUpdateRequest>, OrderService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "Enter JWT token",
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<MojeAutoContext>();
    db.Database.Migrate();
    Seeder.Seed(db);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();