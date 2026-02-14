using LlmQuizGenerator.Models;

namespace LlmQuizGenerator.Repository;

public interface ILogRepository
{
    Task AddLogAsync(Guid id, QuizLog quizLog);
    Task<QuizLog?> GetQuizLogByIdAsync(Guid id);
    Task<IEnumerable<QuizLog>> GetAllLogsAsync();
}