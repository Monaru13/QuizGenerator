using LlmQuizGenerator.GptApi;
using LlmQuizGenerator.Models;
using LlmQuizGenerator.Repository;

namespace LlmQuizGenerator.Generation;

public class QuizGeneratorService(
    IGptQuizGenerator gptQuizGenerator,
    IQuizRepository quizRepository,
    ILogRepository logRepository
)
    : IQuizGeneratorService
{
    public async Task<Quiz> GenerateQuizAsync(QuizGeneratorOptions options)
    {
        var llmQuizResult = await gptQuizGenerator.GenerateQuizAsync(options);
        var quiz = QuizMapper.MapResponseQuizToQuiz(llmQuizResult.ResponseQuiz, options);
        
        await quizRepository.AddQuizAsync(quiz);
        await logRepository.AddLogAsync(quiz.Id, new QuizLog(quiz.Id, llmQuizResult, quiz));

        return quiz;
    }

    public async Task<Quiz> RegenerateQuizAsync(Guid id, QuizGeneratorOptions options)
    {
        var responseQuiz = await gptQuizGenerator.GenerateQuizAsync(options);
        var quiz = QuizMapper.MapResponseQuizToQuiz(responseQuiz.ResponseQuiz, options, id);
        
        await quizRepository.UpdateQuizAsync(id, quiz);
        return quiz;
    }

    public async Task<Quiz?> GetQuizAsync(Guid id)
    {
        return await quizRepository.GetQuizByIdAsync(id);
    }

    public async Task<IEnumerable<Quiz>> GetAllQuizzesAsync()
    {
        return await quizRepository.GetAllQuizzesAsync();
    }

    public async Task<Quiz?> EditQuizAsync(Guid id, Quiz quiz)
    {
        if (await quizRepository.GetQuizByIdAsync(id) is not { } quizToEdit) 
            return null;
        
        await quizRepository.UpdateQuizAsync(id, quiz);
        
        return quizToEdit;
    }

    public async Task<bool> DeleteQuizAsync(Guid id)
    {
        return await quizRepository.DeleteQuizAsync(id);
    }

    public async Task<IEnumerable<QuizLog>> GetAllLogsAsync()
    {
        return await logRepository.GetAllLogsAsync();
    }

    public async Task<QuizLog?> GetLogAsync(Guid id)
    {
        return await logRepository.GetQuizLogByIdAsync(id);
    }
}