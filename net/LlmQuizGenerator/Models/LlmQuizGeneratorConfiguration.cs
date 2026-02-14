namespace LlmQuizGenerator.Models;

public class LlmQuizGeneratorConfiguration
{
    // OpenAI
    public string ApiKey { get; set; } = string.Empty;
    public string? DefaultModel { get; set; }
    public int MaxOutputTokenCountPerQuestion { get; set; } = 200;

    // Baza danych generatora (SQLite)
    public string QuizDbConnectionString { get; set; } = string.Empty;
}