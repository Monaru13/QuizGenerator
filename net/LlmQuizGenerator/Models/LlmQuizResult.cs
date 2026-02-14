namespace LlmQuizGenerator.Models;

public record LlmQuizResult(
    ResponseQuiz ResponseQuiz, 
    object CallDetails,
    UsageInfo? UsageInfo,
    TimeSpan TimeSpan);
    
public record UsageInfo(
    string ModelName,
    decimal Input1MTokenPriceUsd,
    decimal Output1MTokenPriceUsd,
    decimal InputTokenPriceUsd,
    decimal OutputTokenPriceUsd,
    int InputTokenCount,
    int OutputTokenCount,
    decimal InputPriceUsd,
    decimal OutputPriceUsd,
    decimal TotalPriceUsd,
    decimal EstimatedTotalPricePlnGr);