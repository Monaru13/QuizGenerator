using LlmQuizGenerator.Generation;

namespace LlmQuizGenerator.Models;

public record Quiz(
    Guid Id, 
    string Name, 
    QuizQuestion[] Questions, 
    QuizGeneratorOptions Options, 
    DateTime CreatedAt = default
)
{
    public DateTime CreatedAt { get; init; } = CreatedAt == default ? DateTime.UtcNow : CreatedAt;
    public override string ToString() =>
        $"Quiz: {Name} (ID: {Id})\n" +
        $"Test: {Name}\n{string.Join("\n", Questions.Select(q => q.ToString()))}";
}

public record QuizQuestion(string Text, QuizAnswer[] Answers)
{
    public override string ToString() =>
        $"Question: {Text}\n{string.Join("\n", Answers.Select(a => a.ToString()))}";
}

public record QuizAnswer(string Text, bool IsCorrect)
{
    public override string ToString() =>
        $"  - {Text} (Correct: {IsCorrect})";
}