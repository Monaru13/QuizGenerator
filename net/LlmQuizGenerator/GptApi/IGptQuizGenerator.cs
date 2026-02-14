using LlmQuizGenerator.Generation;
using LlmQuizGenerator.Models;

namespace LlmQuizGenerator.GptApi;

public interface IGptQuizGenerator
{
    Task<LlmQuizResult> GenerateQuizAsync(QuizGeneratorOptions options);
}