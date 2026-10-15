
using furniture_BE.Backend.Data;
using furniture_BE.Hubs;
using furniture_BE.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using Microsoft.AspNetCore.RateLimiting;
using System.Security.Claims;
using System.Text;
using System.Threading.RateLimiting;

namespace furniture_BE
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
                });
            builder.Services.AddOpenApi();
            var jwtKey = builder.Configuration["Jwt:Key"];
            if (string.IsNullOrWhiteSpace(jwtKey))
                throw new InvalidOperationException("Missing Jwt:Key configuration.");
            builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
                        ValidateIssuer = true,
                        ValidIssuer = builder.Configuration["Jwt:Issuer"],
                        ValidateAudience = true,
                        ValidAudience = builder.Configuration["Jwt:Audience"],
                        ValidateLifetime = true,
                        ClockSkew = TimeSpan.FromMinutes(1)
                    };
                    options.Events = new JwtBearerEvents
                    {
                        OnMessageReceived = context =>
                        {
                            var accessToken = context.Request.Query["access_token"];
                            if (!string.IsNullOrWhiteSpace(accessToken) &&
                                (context.HttpContext.Request.Path.StartsWithSegments("/hubs/support") ||
                                 context.HttpContext.Request.Path.StartsWithSegments("/hubs/delivery")))
                            {
                                context.Token = accessToken;
                            }

                            return Task.CompletedTask;
                        }
                    };
                });
            builder.Services.AddSignalR();
            builder.Services.AddRateLimiter(options =>
            {
                options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
                options.OnRejected = async (context, cancellationToken) =>
                {
                    context.HttpContext.Response.ContentType = "application/json; charset=utf-8";
                    await context.HttpContext.Response.WriteAsJsonAsync(
                        new
                        {
                            Message = "Bạn đang gửi tin nhắn quá nhanh. Vui lòng chờ một chút rồi thử lại."
                        },
                        cancellationToken);
                };
                options.AddPolicy("support-messages", context =>
                {
                    var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
                    var partitionKey = string.IsNullOrWhiteSpace(userId)
                        ? context.Connection.RemoteIpAddress?.ToString() ?? "anonymous"
                        : $"user:{userId}";
                    return RateLimitPartition.GetFixedWindowLimiter(
                        partitionKey,
                        _ => new FixedWindowRateLimiterOptions
                        {
                            PermitLimit = 20,
                            Window = TimeSpan.FromMinutes(1),
                            QueueLimit = 0,
                            AutoReplenishment = true
                        });
                });
            });
            builder.Services.AddScoped<JwtTokenService>();
            builder.Services.AddScoped<SmtpEmailService>();
            builder.Services.AddScoped<ReviewModerationService>();
            builder.Services.AddSingleton<ProductImageStorage>();
            builder.Services.AddScoped<RecommendationService>();
            builder.Services.AddScoped<SupportRealtimeNotifier>();
            builder.Services.AddScoped<DeliveryRealtimeNotifier>();
            builder.Services.AddScoped<RoomDesignStorage>();
            builder.Services.AddScoped<OpenAiImageHarmonizationService>();
            builder.Services.AddScoped<GeminiImageHarmonizationService>();
            builder.Services.AddScoped<ImageHarmonizationService>();
            builder.Services.AddHostedService<RoomDesignCleanupService>();
            builder.Services.AddHttpClient();
            builder.Services.AddHttpClient("BackgroundRemoval", client =>
            {
                client.Timeout = TimeSpan.FromMinutes(3);
            });
            builder.Services.AddHttpClient("SceneAnalysis", client =>
            {
                client.Timeout = TimeSpan.FromMinutes(5);
            });
            builder.Services.AddHttpClient("OpenAIImages", client =>
            {
                client.Timeout = TimeSpan.FromMinutes(4);
            });
            builder.Services.AddHttpClient("OpenAIModeration", client =>
            {
                client.Timeout = TimeSpan.FromSeconds(20);
            });
            builder.Services.AddHttpClient("OpenAIChat", client =>
            {
                client.Timeout = TimeSpan.FromSeconds(60);
            });
            builder.Services.AddHttpClient("GeminiImages", client =>
            {
                client.Timeout = TimeSpan.FromMinutes(4);
            });
            builder.Services.AddHttpClient("GeminiChat", client =>
            {
                client.Timeout = TimeSpan.FromSeconds(60);
            });
            //Đăng ký Dbcontext 
            builder.Services.AddDbContext<AppDbContext>(options =>
                options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
            // 
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("Frontend",
                    policy =>
                    {
                        var frontendUrl = builder.Configuration["FrontendUrl"] ?? "http://localhost:8085";
                        var allowedOrigins = new[]
                        {
                            frontendUrl.TrimEnd('/'),
                            "http://localhost:8080",
                            "http://127.0.0.1:8080",
                            "http://localhost:8085",
                            "http://127.0.0.1:8085"
                        }.Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
                        policy.WithOrigins(allowedOrigins)
                              .AllowAnyMethod()
                              .AllowAnyHeader()
                              .AllowCredentials();
                    });
            });
            var app = builder.Build();
            var productImageStorage = app.Services.GetRequiredService<ProductImageStorage>();
            productImageStorage.MigrateLegacyFiles();


            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
            }

            app.UseStaticFiles(new StaticFileOptions
            {
                OnPrepareResponse = ctx =>
                {
                    ctx.Context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
                }
            });
            app.UseStaticFiles(new StaticFileOptions
            {
                FileProvider = new PhysicalFileProvider(productImageStorage.RootPath),
                RequestPath = ProductImageStorage.RequestPath,
                OnPrepareResponse = ctx =>
                {
                    ctx.Context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
                    ctx.Context.Response.Headers.Append("Cache-Control", "public,max-age=3600");
                }
            });
            app.UseCors("Frontend");

            app.UseAuthentication();
            app.UseRateLimiter();
            app.UseAuthorization();


            app.MapControllers();
            app.MapHub<SupportChatHub>("/hubs/support");
            app.MapHub<DeliveryHub>("/hubs/delivery");
            
            app.Run();
        }
    }
}

