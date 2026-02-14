using Microsoft.AspNetCore.Mvc;
using QuizGeneratorService.Models;
using QuizGeneratorService.Services;

namespace QuizGeneratorService.Endpoints;

/// <summary>
/// Minimal API endpoints dla eksportu testów
/// </summary>
public static class ExportEndpoints
{
    /// <summary>
    /// Konfiguruje endpoints dla eksportu testów
    /// </summary>
    public static void MapExportEndpoints(this IEndpointRouteBuilder app)
    {
        var exportGroup = app.MapGroup("/api/export")
            .WithTags("Export")
            .WithDescription("Endpoints do eksportu testów w formatach PDF i DOCX");

        // GET /api/export/pdf/{id} - Eksport do PDF
        exportGroup.MapGet("/pdf/{id:guid}", ExportToPdf)
            .WithName("ExportToPdf")
            .WithSummary("Eksportuje quiz do formatu PDF")
            .WithDescription("Generuje test w formacie PDF na podstawie parametrów. Obsługuje różne layouty i randomizację.")
            .WithOpenApi();
    }

    /// <summary>
    /// Eksportuje quiz do PDF
    /// </summary>
    private static async Task<IResult> ExportToPdf(
        Guid id,
        [FromServices] ITestExportService exportService,
        [FromQuery] int? questionCount = null,
        [FromQuery] int variantsCount = 1,
        [FromQuery] ExportLayout layout = ExportLayout.Standard,
        [FromQuery] bool includeAnswerKey = true,
        [FromQuery] bool shuffleQuestions = true,
        [FromQuery] bool shuffleAnswers = true,
        [FromQuery] int? randomSeed = null,
        [FromQuery] bool preventQuestionSplit = true)
    {
        try
        {
            var parameters = new ExportParameters
            {
                QuizId = id,
                Format = ExportFormat.PDF,
                Layout = layout,
                QuestionCount = questionCount,
                VariantsCount = Math.Max(1, Math.Min(4, variantsCount)), // Ograniczenie 1-4
                IncludeAnswerKey = includeAnswerKey,
                ShuffleQuestions = shuffleQuestions,
                ShuffleAnswers = shuffleAnswers,
                RandomSeed = randomSeed,
                PreventQuestionSplit = preventQuestionSplit
            };

            var result = await exportService.ExportQuizAsync(parameters);
            
            return Results.File(
                result.FileData,
                result.ContentType,
                result.FileName);
        }
        catch (ArgumentException ex)
        {
            return Results.BadRequest(new 
            { 
                error = "Nieprawidłowe parametry", 
                message = ex.Message 
            });
        }
        catch (InvalidOperationException ex)
        {
            return Results.NotFound(new 
            { 
                error = "Zasób nie znaleziony", 
                message = ex.Message 
            });
        }
        catch (Exception ex)
        {
            return Results.Problem(
                title: "Błąd eksportu",
                detail: ex.Message,
                statusCode: 500);
        }
    }
}