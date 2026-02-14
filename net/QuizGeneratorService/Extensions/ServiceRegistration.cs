using QuizGeneratorService.Endpoints;
using QuizGeneratorService.Services;
using QuizGeneratorService.Services.Generators;
using QuizGeneratorService.Services.Utilities;

namespace QuizGeneratorService.Extensions;

/// <summary>
/// Rozszerzenia dla konfiguracji Dependency Injection dla eksportu testów
/// </summary>
public static class ExportServiceExtensions
{
    /// <summary>
    /// Rejestruje wszystkie serwisy związane z eksportem testów
    /// </summary>
    public static IServiceCollection AddTestExportServices(this IServiceCollection services)
    {
        // Główny serwis eksportu
        services.AddScoped<ITestExportService, TestExportService>();
        
        // Generatory dokumentów
        services.AddScoped<PdfGenerator>();
        
        // Serwisy pomocnicze
        services.AddScoped<ValidationService>();
        //services.AddScoped<LayoutCalculator>();
        
        return services;
    }
    
    /// <summary>
    /// Konfiguruje endpoints dla eksportu testów
    /// </summary>
    public static WebApplication MapEndpoints(this WebApplication app)
    {
        app.MapQuizEndpoints();
        app.MapExportEndpoints();
        
        return app;
    }
}