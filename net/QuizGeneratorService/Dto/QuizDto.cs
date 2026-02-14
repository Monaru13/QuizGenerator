using LlmQuizGenerator.Generation;
using LlmQuizGenerator.Models;

namespace QuizGeneratorService.Dto;

public record QuizDto(
    Guid Id,
    string Name,
    int QuestionCount,
    int AnswerVariants,
    QuizDifficultyLevel DifficultyLevel,
    DateTime CreatedAt);

public record QuizDetailDto(
    Guid Id,
    string Name,
    QuizQuestion[] Questions,
    QuizGeneratorOptions Options,
    string? ModelName,
    decimal? EstimatedPricePln,
    TimeSpan? TimeSpan,
    DateTime CreatedAt);