using LlmQuizGenerator.Generation;
using LlmQuizGenerator.Models;

namespace QuizGeneratorService.Dto;

public record QuizLogDto(
    Guid QuizId,
    string Name,
    int QuestionCount,
    int AnswerVariants,
    QuizDifficultyLevel DifficultyLevel,
    TimeSpan TimeSpan,
    string ModelName,
    decimal TotalPriceUsd,
    decimal EstimatedTotalPricePlnGr,
    DateTime CreatedAt);

public record QuizLogDetailDto(
    Guid QuizId,
    LlmQuizResult LlmQuizResult,
    QuizDetailDto Quiz,
    DateTime CreatedAt);