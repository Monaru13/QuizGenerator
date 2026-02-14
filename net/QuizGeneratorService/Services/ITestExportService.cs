using QuizGeneratorService.Models;

namespace QuizGeneratorService.Services;

/// <summary>
/// Interfejs głównego serwisu eksportu testów
/// </summary>
public interface ITestExportService
{
    /// <summary>
    /// Eksportuje quiz do pliku PDF lub DOCX
    /// </summary>
    Task<ExportResult> ExportQuizAsync(ExportParameters parameters);
}