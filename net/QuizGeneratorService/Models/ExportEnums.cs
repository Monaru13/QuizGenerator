using System.Text.Json.Serialization;

namespace QuizGeneratorService.Models;

/// <summary>
/// Typy layoutów dla eksportu testów
/// </summary>
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ExportLayout
{
    /// <summary>
    /// Standardowy layout - jedno pytanie na stronę, duże marginesy
    /// </summary>
    Standard,
    
    /// <summary>
    /// Kompaktowy layout - minimalne marginesy, optymalizacja miejsca
    /// </summary>
    Compact,
    
    /// <summary>
    /// Dwukolumnowy layout - dwa testy obok siebie
    /// </summary>
    Double,
    
    /// <summary>
    /// Layout ekonomiczny - maksymalne wykorzystanie papieru
    /// </summary>
    Economic
}

/// <summary>
/// Typy formatów eksportu
/// </summary>
public enum ExportFormat
{
    PDF,
    DOCX
}

/// <summary>
/// Typy testów (warianty)
/// </summary>
public enum TestVariant
{
    A = 0,
    B = 1,
    C = 2,
    D = 3
}