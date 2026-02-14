using LlmQuizGenerator.Generation;
using LlmQuizGenerator.GptApi;
using LlmQuizGenerator.Models;
using QuizGeneratorService.Dto;
using QuizGeneratorService.Mappers;

namespace QuizGeneratorService.Endpoints;

/// <summary>
/// Minimal API endpoints dla quizów i logów
/// </summary>
public static class QuizEndpoints
{
    /// <summary>
    /// Konfiguruje endpoints dla quizów
    /// </summary>
    public static void MapQuizEndpoints(this IEndpointRouteBuilder app)
    {
        var quizGroup = app.MapGroup("/api/quiz")
            .WithTags("Quizzes")
            .WithDescription("Endpoints do zarządzania quizami");

        // GET /api/quiz - Pobiera wszystkie quizy
        quizGroup.MapGet("/", GetQuizzes)
            .Produces<QuizDto[]>()
            .Produces(StatusCodes.Status404NotFound)
            .WithName("GetQuizzes")
            .WithSummary("Pobiera wszystkie quizy")
            .WithOpenApi();

        // GET /api/quiz/{id} - Pobiera szczegóły quizu
        quizGroup.MapGet("/{id:guid}", GetQuiz)
            .Produces<QuizDetailDto>()
            .Produces(StatusCodes.Status404NotFound)
            .WithName("GetQuiz")
            .WithSummary("Pobiera szczegóły quizu")
            .WithOpenApi();

        // POST /api/quiz - Generuje nowy quiz
        quizGroup.MapPost("/", GenerateQuiz)
            .Produces<QuizDetailDto>()
            .Produces(StatusCodes.Status400BadRequest)
            .WithName("GenerateQuiz")
            .WithSummary("Generuje test jednokrotnego wyboru")
            .WithOpenApi();

        // PUT /api/quiz/{id} - Edytuje quiz
        quizGroup.MapPut("/{id:guid}", EditQuiz)
            .Produces<QuizDetailDto>()
            .Produces(StatusCodes.Status404NotFound)
            .WithName("EditQuiz")
            .WithSummary("Edytuje istniejący quiz")
            .WithOpenApi();

        // DELETE /api/quiz/{id} - Usuwa quiz
        quizGroup.MapDelete("/{id:guid}", DeleteQuiz)
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .WithName("DeleteQuiz")
            .WithSummary("Usuwa quiz")
            .WithOpenApi();

        var logsGroup = app.MapGroup("/api/logs")
            .WithTags("Logs")
            .WithDescription("Endpoints do zarządzania logami");

        // GET /api/logs - Pobiera wszystkie logi
        logsGroup.MapGet("/", GetLogs)
            .Produces<QuizLogDto[]>()
            .WithName("GetLogs")
            .WithSummary("Pobiera wszystkie logi")
            .WithOpenApi();

        // GET /api/logs/{id} - Pobiera log o ID
        logsGroup.MapGet("/{id:guid}", GetLogById)
            .Produces<QuizLogDetailDto>()
            .Produces(StatusCodes.Status404NotFound)
            .WithName("GetLogById")
            .WithSummary("Pobiera log o podanym ID")
            .WithOpenApi();

        var gptGroup = app.MapGroup("/api/gpt")
            .WithTags("GPT")
            .WithDescription("Endpoints dla modeli GPT");

        // GET /api/gpt/models - Pobiera modele GPT
        gptGroup.MapGet("/models", GetGptModels)
            .Produces<List<GptModelInfo>>()
            .WithName("GetGptModels")
            .WithSummary("Pobiera listę dostępnych modeli GPT")
            .WithOpenApi();
    }

    // GET /api/quiz
    private static async Task<IResult> GetQuizzes(IQuizGeneratorService quizService)
    {
        var quizzes = (await quizService.GetAllQuizzesAsync()).ToArray();
        
        return Results.Ok(quizzes.Select(QuizDtoMapper.ToQuizDto).ToArray());
    }

    // GET /api/quiz/{id}
    private static async Task<IResult> GetQuiz(IQuizGeneratorService quizService, Guid id)
    {
        var quiz = await quizService.GetQuizAsync(id);
        var log = await quizService.GetLogAsync(id);

        return quiz is null 
            ? Results.NotFound() 
            : Results.Ok(QuizDtoMapper.ToQuizDetailDto(quiz, log));
    }

    // POST /api/quiz
    private static async Task<IResult> GenerateQuiz(IQuizGeneratorService quizService, QuizGeneratorOptions options)
    {
        if (!string.IsNullOrEmpty(options.ModelName) && !GptModelInfos.ModelExists(options.ModelName))
            return Results.BadRequest($"Model {options.ModelName} nie dostępny");

        var quiz = await quizService.GenerateQuizAsync(options);
        
        return Results.Ok(QuizDtoMapper.ToQuizDetailDto(quiz));
    }

    // PUT /api/quiz/{id}
    private static async Task<IResult> EditQuiz(IQuizGeneratorService quizService, Guid id, Quiz quiz)
    {
        var updatedQuiz = await quizService.EditQuizAsync(id, quiz);
        
        return updatedQuiz is null
            ? Results.NotFound($"Quiz o ID {id} nie istnieje.")
            : Results.Ok(QuizDtoMapper.ToQuizDetailDto(updatedQuiz));
    }

    // DELETE /api/quiz/{id}
    private static async Task<IResult> DeleteQuiz(IQuizGeneratorService quizService, Guid id)
    {
        var success = await quizService.DeleteQuizAsync(id);
        
        return success 
            ? Results.NoContent() 
            : Results.NotFound($"Quiz o ID {id} nie istnieje.");
    }

    // GET /api/logs
    private static async Task<IResult> GetLogs(IQuizGeneratorService quizService)
    {
        var logs = await quizService.GetAllLogsAsync();
        
        return Results.Ok(logs.Select(QuizLogDtoMapper.ToQuizLogDto).ToArray());
    }

    // GET /api/logs/{id}
    private static async Task<IResult> GetLogById(IQuizGeneratorService quizService, Guid id)
    {
        var log = await quizService.GetLogAsync(id);
        
        return log is null 
            ? Results.NotFound() 
            : Results.Ok(QuizLogDtoMapper.ToQuizLogDetailDto(log));
    }

    // GET /api/gpt/models
    private static IResult GetGptModels()
    {
        return Results.Ok(GptModelInfos.ModelInfos);
    }
}
