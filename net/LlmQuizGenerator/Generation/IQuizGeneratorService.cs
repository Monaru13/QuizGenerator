using LlmQuizGenerator.Models;

namespace LlmQuizGenerator.Generation;

public interface IQuizGeneratorService
{
    Task<Quiz> GenerateQuizAsync(QuizGeneratorOptions options);
    Task<Quiz?> GetQuizAsync(Guid id);
    Task<IEnumerable<Quiz>> GetAllQuizzesAsync();
    Task<Quiz?> EditQuizAsync(Guid id, Quiz quiz);
    Task<bool> DeleteQuizAsync(Guid id);
    Task<IEnumerable<QuizLog>> GetAllLogsAsync();
    Task<QuizLog?> GetLogAsync(Guid id);
}