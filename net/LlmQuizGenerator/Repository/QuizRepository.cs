using System.Text.Json;
using LlmQuizGenerator.Data;
using LlmQuizGenerator.Models;
using Microsoft.EntityFrameworkCore;

namespace LlmQuizGenerator.Repository;

internal class QuizRepository : IQuizRepository
{
    private readonly AppDbContext _dbContext;

    public QuizRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddQuizAsync(Quiz quizSet)
    {
        var entity = new QuizSetEntity
        {
            Id = quizSet.Id,
            JsonData = JsonSerializer.Serialize(quizSet)
        };

        _dbContext.QuizSets.Add(entity);
        await _dbContext.SaveChangesAsync();
    }

    public async Task<Quiz?> GetQuizByIdAsync(Guid id)
    {
        var entity = await _dbContext.QuizSets.FindAsync(id);
        return entity is not null ? JsonSerializer.Deserialize<Quiz>(entity.JsonData) : null;
    }

    public async Task<bool> UpdateQuizAsync(Guid id, Quiz updatedQuizSet)
    {
        var entity = await _dbContext.QuizSets.FindAsync(id);
        if (entity is null) return false;

        entity.JsonData = JsonSerializer.Serialize(updatedQuizSet);
        await _dbContext.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteQuizAsync(Guid id)
    {
        var entity = await _dbContext.QuizSets.FindAsync(id);
        if (entity is null) return false;

        _dbContext.QuizSets.Remove(entity);
        await _dbContext.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<Quiz>> GetAllQuizzesAsync()
    {
        var quizEntities = await _dbContext.QuizSets.ToListAsync();

        return quizEntities
            .Select(q => JsonSerializer.Deserialize<Quiz>(q.JsonData))
            .Where(q => q is not null)
            .OrderByDescending(q => q.CreatedAt);
    }
}