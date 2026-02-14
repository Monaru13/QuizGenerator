using LlmQuizGenerator.Data;
using LlmQuizGenerator.Generation;
using LlmQuizGenerator.GptApi;
using LlmQuizGenerator.Models;
using LlmQuizGenerator.Repository;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace LlmQuizGenerator;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddQuizGeneratorService(this IServiceCollection services, LlmQuizGeneratorConfiguration configuration)
    {
        AddScopedServices(services, configuration);
        AddDataContext(services, configuration.QuizDbConnectionString);

        return services;
    }

    private static void AddDataContext(IServiceCollection services, string connectionString)
    {
        // Rejestracja bazy SQLite
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlite(connectionString));
        
        // Automatyczne tworzenie bazy danych
        using var scope = services.BuildServiceProvider().CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        db.Database.EnsureCreated();
    }

    private static void AddScopedServices(IServiceCollection services, LlmQuizGeneratorConfiguration configuration)
    {
        // Rejestrujemy wewnętrzne zależności jako "wewnętrzne"
        services.AddScoped<IQuizRepository, QuizRepository>();
        services.AddScoped<ILogRepository, LogRepository>();
        services.AddScoped<IGptQuizGenerator>(_ => new GptQuizGenerator(configuration));

        // Udostępniamy na zewnątrz tylko IQuizGeneratorService
        services.AddScoped<IQuizGeneratorService, QuizGeneratorService>();
    }
}
