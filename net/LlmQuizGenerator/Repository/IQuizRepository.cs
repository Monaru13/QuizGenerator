using LlmQuizGenerator.Models;

namespace LlmQuizGenerator.Repository;

public interface IQuizRepository
{
    Task AddQuizAsync(Quiz quiz);
    Task<Quiz?> GetQuizByIdAsync(Guid id);
    Task<bool> UpdateQuizAsync(Guid id, Quiz quiz);
    Task<bool> DeleteQuizAsync(Guid id);
    Task<IEnumerable<Quiz>> GetAllQuizzesAsync();
}