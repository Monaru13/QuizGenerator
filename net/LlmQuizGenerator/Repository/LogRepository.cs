using System.Text.Json;
using LlmQuizGenerator.Data;
using LlmQuizGenerator.Models;
using Microsoft.EntityFrameworkCore;

namespace LlmQuizGenerator.Repository;

internal class LogRepository(AppDbContext dbContext) : ILogRepository
{
    public async Task AddLogAsync(Guid id, QuizLog quizLog)
    {
        var entity = new QuizLogEntity
        {
            Id = id,
            JsonData = JsonSerializer.Serialize(quizLog)
        };

        dbContext.QuizLogs.Add(entity);
        await dbContext.SaveChangesAsync();
    }

    public async Task<QuizLog?> GetQuizLogByIdAsync(Guid id)
    {
        var entity = await dbContext.QuizLogs.FindAsync(id);
        return entity is not null ? JsonSerializer.Deserialize<QuizLog>(entity.JsonData) : null;
    }

    public async Task<IEnumerable<QuizLog>> GetAllLogsAsync()
    {
        var quizLogEntities = await dbContext.QuizLogs.ToListAsync();

        return quizLogEntities
            .Select(q => JsonSerializer.Deserialize<QuizLog>(q.JsonData))
            .Where(q => q is not null)
            .OrderByDescending(q => q.CreatedAt);;
    }
}