using LlmQuizGenerator.Models;
using QuizGeneratorService.Dto;

namespace QuizGeneratorService.Mappers;

public static class QuizDtoMapper
{
    public static QuizDto ToQuizDto(Quiz quiz)
    {
        return new QuizDto(
            Id: quiz.Id,
            Name: quiz.Name,
            QuestionCount: quiz.Questions.Length,
            AnswerVariants: quiz.Options.AnswerVariants,
            DifficultyLevel: quiz.Options.DifficultyLevel,
            CreatedAt: quiz.CreatedAt
        );
    }

    public static QuizDetailDto ToQuizDetailDto(Quiz quiz, QuizLog? log = null)
    {
        return new QuizDetailDto(
            Id: quiz.Id,
            Name: quiz.Name,
            Questions: quiz.Questions,
            Options: quiz.Options,
            ModelName: log?.LlmQuizResult.UsageInfo?.ModelName,
            EstimatedPricePln: log?.LlmQuizResult.UsageInfo?.EstimatedTotalPricePlnGr / 100,
            TimeSpan: log?.LlmQuizResult.TimeSpan,
            CreatedAt: quiz.CreatedAt
        );
    }
}