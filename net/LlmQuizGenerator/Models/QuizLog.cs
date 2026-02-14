namespace LlmQuizGenerator.Models;

public record QuizLog(
    Guid QuizId,
    LlmQuizResult LlmQuizResult,
    Quiz Quiz,
    DateTime CreatedAt = default)
{
    public DateTime CreatedAt { get; init; } = CreatedAt == default ? DateTime.UtcNow : CreatedAt;
};