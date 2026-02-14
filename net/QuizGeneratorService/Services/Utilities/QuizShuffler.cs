using LlmQuizGenerator.Models;
using QuizGeneratorService.Models;

namespace QuizGeneratorService.Services.Utilities;

/// <summary>
/// Serwis do mieszania kolejności pytań i odpowiedzi w quizach
/// </summary>
public class QuizShuffler(int? seed = null)
{
    private readonly Random _random = seed.HasValue ? new Random(seed.Value) : new Random();

    /// <summary>
    /// Tworzy warianty testu z przemieszanymi pytaniami i odpowiedziami
    /// </summary>
    public List<ExportTestVariant> CreateTestVariants(
        Quiz originalQuiz,
        ExportParameters parameters)
    {
        return Enumerable.Range(0, parameters.VariantsCount)
            .Select(i => CreateSingleVariant(originalQuiz, parameters, (TestVariant)i))
            .ToList();
    }
    
    /// <summary>
    /// Tworzy pojedynczy wariant testu
    /// </summary>
    private ExportTestVariant CreateSingleVariant(
        Quiz originalQuiz,
        ExportParameters parameters,
        TestVariant variantType)
    {
        // Wybierz pytania do eksportu
        var questionsToExport = SelectQuestions(originalQuiz.Questions, parameters.QuestionCount);
        
        // Przemieszaj pytania jeśli wymagane
        if (parameters.ShuffleQuestions)
        {
            questionsToExport = ShuffleArray(questionsToExport);
        }
        
        // Przygotuj pytania do eksportu
        var exportQuestions = questionsToExport
            .Select((question, i) => PrepareExportQuestion(question, i + 1, parameters.ShuffleAnswers))
            .ToList();

        return new ExportTestVariant
        {
            Variant = variantType,
            TestName = originalQuiz.Name,
            Questions = exportQuestions,
            GeneratedAt = DateTime.Now
        };
    }
    
    /// <summary>
    /// Wybiera określoną liczbę pytań z quizu
    /// </summary>
    private QuizQuestion[] SelectQuestions(QuizQuestion[] allQuestions, int? count)
    {
        if (!count.HasValue || count.Value >= allQuestions.Length)
        {
            return allQuestions;
        }
        
        // Losowo wybierz pytania
        return allQuestions
            .OrderBy(_ => _random.Next())
            .Take(count.Value)
            .ToArray();
    }
    
    /// <summary>
    /// Przemieszaj tablicę elementów
    /// </summary>
    private T[] ShuffleArray<T>(T[] array)
    {
        var shuffled = array.ToArray();
        
        for (var i = shuffled.Length - 1; i > 0; i--)
        {
            var j = _random.Next(i + 1);
            (shuffled[i], shuffled[j]) = (shuffled[j], shuffled[i]);
        }
        
        return shuffled;
    }
    
    /// <summary>
    /// Przygotowuje pytanie do eksportu z przemieszanymi odpowiedziami
    /// </summary>
    private ExportQuestion PrepareExportQuestion(
        QuizQuestion originalQuestion,
        int questionNumber,
        bool shuffleAnswers)
    {
        var originalAnswers = originalQuestion.Answers.ToArray();
        var answersToUse = originalAnswers;
        
        // Przemieszaj odpowiedzi jeśli wymagane
        if (shuffleAnswers)
        {
            answersToUse = ShuffleArray(originalAnswers);
        }
        
        // Znajdź nowy indeks poprawnej odpowiedzi po przemieszaniu
        var newCorrectIndex = Array.FindIndex(answersToUse, answer => answer.IsCorrect);
        
        // Przygotuj odpowiedzi do eksportu
        var exportAnswers = answersToUse
            .Select((answer, index) => new ExportAnswer
            {
                Letter = (char)('a' + index),
                Text = answer.Text,
                IsCorrect = answer.IsCorrect
            })
            .ToList();
        
        return new ExportQuestion
        {
            Number = questionNumber,
            Text = originalQuestion.Text,
            Answers = exportAnswers,
            CorrectAnswerIndex = newCorrectIndex
        };
    }
}