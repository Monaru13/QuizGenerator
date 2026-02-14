using LlmQuizGenerator.Models;
using QuizGeneratorService.Dto;

namespace QuizGeneratorService.Mappers;

public static class QuizLogDtoMapper
{
    public static QuizLogDto ToQuizLogDto(QuizLog quizLog)
    {
        var usage = quizLog.LlmQuizResult.UsageInfo;
        return new QuizLogDto(
            QuizId: quizLog.QuizId,
            Name: quizLog.Quiz.Name,
            QuestionCount: quizLog.Quiz.Options.QuestionCount,
            AnswerVariants: quizLog.Quiz.Options.AnswerVariants,
            DifficultyLevel: quizLog.Quiz.Options.DifficultyLevel,
            TimeSpan: quizLog.LlmQuizResult.TimeSpan,
            ModelName: usage?.ModelName ?? "unknown",
            TotalPriceUsd: usage?.TotalPriceUsd ?? 0m,
            EstimatedTotalPricePlnGr: usage?.EstimatedTotalPricePlnGr ?? 0m,
            CreatedAt: quizLog.CreatedAt
        );
    }

    public static QuizLogDetailDto ToQuizLogDetailDto(QuizLog quizLog)
    {
        return new QuizLogDetailDto(
            QuizId: quizLog.QuizId,
            LlmQuizResult: quizLog.LlmQuizResult,
            Quiz: QuizDtoMapper.ToQuizDetailDto(quizLog.Quiz),
            CreatedAt: quizLog.CreatedAt);
    }
}