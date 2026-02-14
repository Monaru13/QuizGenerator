using System.Text.Json.Serialization;

namespace LlmQuizGenerator.Generation;

public record QuizGeneratorOptions(
    string Topic,
    int QuestionCount,
    QuizDifficultyLevel DifficultyLevel,
    int AnswerVariants,
    string? ModelName = null
);

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum QuizDifficultyLevel
{
    Easy = 1,
    Medium,
    Hard
}