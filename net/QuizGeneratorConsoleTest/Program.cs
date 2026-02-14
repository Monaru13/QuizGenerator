using LlmQuizGenerator;
using LlmQuizGenerator.Generation;
using LlmQuizGenerator.Models;
using Microsoft.Extensions.DependencyInjection;

var services = new ServiceCollection();

// 1️⃣ Rejestracja serwisów w DI
services.AddQuizGeneratorService(new LlmQuizGeneratorConfiguration
{
    ApiKey = "",
    MaxOutputTokenCountPerQuestion = 100,
    QuizDbConnectionString = "Data Source=quiz.db"
});

// 2️⃣ Zbudowanie `ServiceProvider`
await using var provider = services.BuildServiceProvider();

// 3️⃣ Tworzenie `Scope` dla `Scoped` serwisów
using (var scope = provider.CreateScope())
{
    var quizService = scope.ServiceProvider.GetRequiredService<IQuizGeneratorService>();

    var options = new QuizGeneratorOptions(
        "Lotnictwo na ogół nie obejmuje zagadnień związanych z lotami w kosmos, którymi zajmuje się astronautyka...",
        1, 
        QuizDifficultyLevel.Medium, 
        4);

    var quiz = await quizService.GenerateQuizAsync(options);

    Console.WriteLine("Utworzony QuizSet:\n" + quiz);
}