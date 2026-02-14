using System.Diagnostics;
using LlmQuizGenerator.Generation;
using QuizGeneratorService.Models;
using QuizGeneratorService.Services.Generators;
using QuizGeneratorService.Services.Utilities;

namespace QuizGeneratorService.Services;

/// <summary>
/// Główny serwis eksportu testów - poprawiona wersja
/// </summary>
public class TestExportService(
    IQuizGeneratorService quizService,
    PdfGenerator pdfGenerator)
    : ITestExportService
{
    /// <summary>
    /// Eksportuje quiz do pliku PDF lub DOCX
    /// </summary>
    public async Task<ExportResult> ExportQuizAsync(ExportParameters parameters)
    {
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // Walidacja
            var validation = await ValidateExportParametersAsync(parameters);
            if (!validation.IsValid)
            {
                throw new ArgumentException($"Nieprawidłowe parametry eksportu: {string.Join(", ", validation.Errors)}");
            }
            
            // Pobierz quiz
            var quiz = await quizService.GetQuizAsync(parameters.QuizId);
            if (quiz == null)
            {
                throw new InvalidOperationException($"Quiz o ID {parameters.QuizId} nie został znaleziony");
            }
            
            // Przygotuj dane do eksportu
            var shuffler = new QuizShuffler(parameters.RandomSeed);
            var variants = shuffler.CreateTestVariants(quiz, parameters);

            if (parameters.Format != ExportFormat.PDF)
            {
                throw new NotSupportedException("Format not supported");
            }

            var pdfDocument = pdfGenerator.Generate(variants, parameters);

            var fileData = pdfGenerator.ConvertToBytes(pdfDocument);
            var fileName = GenerateFileName(variants[0], parameters, pdfGenerator.FileExtension);
            var contentType = pdfGenerator.ContentType;

            stopwatch.Stop();
            
            return new ExportResult
            {
                FileData = fileData,
                FileName = fileName,
                ContentType = contentType,
                GeneratedQuestionsCount = variants[0].Questions.Count,
                GeneratedVariantsCount = variants.Count,
                GenerationTime = stopwatch.Elapsed
            };
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            throw new InvalidOperationException($"Błąd podczas eksportu: {ex.Message}", ex);
        }
    }
    
    /// <summary>
    /// Waliduje parametry eksportu
    /// </summary>
    private async Task<ValidationResult> ValidateExportParametersAsync(ExportParameters parameters)
    {
        try
        {
            var quiz = await quizService.GetQuizAsync(parameters.QuizId);
            return ValidationService.ValidateExportParameters(parameters, quiz);
        }
        catch (Exception ex)
        {
            return new ValidationResult
            {
                IsValid = false,
                Errors = [$"Błąd podczas walidacji: {ex.Message}"]
            };
        }
    }
    
    /// <summary>
    /// Generuje nazwę pliku dla eksportu
    /// </summary>
    private static string GenerateFileName(ExportTestVariant primaryVariant, ExportParameters parameters, string extension)
    {
        var testName = SanitizeFileName(primaryVariant.TestName);
        var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        var variantsSuffix = parameters.VariantsCount > 1 ? $"_{parameters.VariantsCount}var" : "";
        var layoutSuffix = parameters.Layout != ExportLayout.Standard ? $"_{parameters.Layout}" : "";
        
        return $"{testName}{variantsSuffix}{layoutSuffix}_{timestamp}{extension}";
    }
    
    /// <summary>
    /// Sanityzuje nazwę pliku, usuwając nieprawidłowe znaki
    /// </summary>
    private static string SanitizeFileName(string fileName)
    {
        if (string.IsNullOrWhiteSpace(fileName))
            return "Quiz";
            
        var invalidChars = Path.GetInvalidFileNameChars();
        var sanitized = new string(fileName
            .Where(c => !invalidChars.Contains(c))
            .ToArray());
            
        return string.IsNullOrWhiteSpace(sanitized) ? "Quiz" : sanitized.Trim();
    }
}