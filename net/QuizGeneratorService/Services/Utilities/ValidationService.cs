using LlmQuizGenerator.Models;
using QuizGeneratorService.Models;

namespace QuizGeneratorService.Services.Utilities;

/// <summary>
/// Serwis do walidacji parametrów eksportu
/// </summary>
public class ValidationService
{
    /// <summary>
    /// Waliduje parametry eksportu
    /// </summary>
    public static ValidationResult ValidateExportParameters(
        ExportParameters parameters, 
        Quiz? quiz)
    {
        var errors = new List<string>();

        if (quiz == null)
        {
            errors.Add("Quiz nie został znaleziony");
            return new ValidationResult { IsValid = false, Errors = errors };
        }

        ValidateQuestionCount(parameters, quiz, errors);
        ValidateVariantsCount(parameters, errors);
        
        return new ValidationResult
        {
            IsValid = errors.Count == 0,
            Errors = errors
        };
    }
    
    /// <summary>
    /// Waliduje liczbę pytań
    /// </summary>
    private static void ValidateQuestionCount(
        ExportParameters parameters, 
        Quiz quiz, 
        List<string> errors)
    {
        var totalQuestions = quiz.Questions?.Length ?? 0;
        
        if (totalQuestions == 0)
        {
            errors.Add("Quiz nie zawiera żadnych pytań");
            return;
        }

        if (!parameters.QuestionCount.HasValue) return;
        var requestedCount = parameters.QuestionCount.Value;
            
        if (requestedCount <= 0)
        {
            errors.Add("Liczba pytań musi być większa od zera");
        }
        else if (requestedCount > totalQuestions)
        {
            errors.Add($"Żądana liczba pytań ({requestedCount}) przekracza liczbę dostępnych pytań ({totalQuestions})");
        }
    }
    
    /// <summary>
    /// Waliduje liczbę wariantów
    /// </summary>
    private static void ValidateVariantsCount(
        ExportParameters parameters, 
        List<string> errors)
    {
        switch (parameters.VariantsCount)
        {
            case <= 0:
                errors.Add("Liczba wariantów musi być większa od zera");
                break;
            case > 4:
                errors.Add("Maksymalna liczba wariantów to 4 (A, B, C, D)");
                break;
        }
    }
}