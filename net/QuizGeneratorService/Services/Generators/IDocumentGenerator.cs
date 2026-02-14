using QuizGeneratorService.Models;

namespace QuizGeneratorService.Services.Generators;

/// <summary>
/// Interfejs dla generatorów dokumentów testowych
/// </summary>
public interface IDocumentGenerator<TDocument>
{
    /// <summary>
    /// Generuje dokument z wieloma wariantami testów
    /// </summary>
    /// <param name="variants">Lista wariantów testów</param>
    /// <param name="parameters">Parametry eksportu</param>
    /// <returns>Wygenerowany dokument</returns>
    TDocument Generate(
        List<ExportTestVariant> variants,
        ExportParameters parameters);
    
    /// <summary>
    /// Konwertuje dokument do tablicy bajtów
    /// </summary>
    /// <param name="document">Dokument do konwersji</param>
    /// <returns>Tablica bajtów reprezentująca dokument</returns>
    byte[] ConvertToBytes(TDocument document);
    
    /// <summary>
    /// Zwraca MIME type dla tego typu dokumentu
    /// </summary>
    string ContentType { get; }
    
    /// <summary>
    /// Zwraca rozszerzenie pliku dla tego typu dokumentu
    /// </summary>
    string FileExtension { get; }
}