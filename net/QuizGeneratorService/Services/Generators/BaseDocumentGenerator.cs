using QuizGeneratorService.Models;

namespace QuizGeneratorService.Services.Generators;

/// <summary>
/// Bazowa klasa dla generatorów dokumentów
/// </summary>
public abstract class BaseDocumentGenerator
{
    protected const string NamePlaceholder = "Imię i nazwisko:";
    protected const string DatePlaceholder = "Data:                    " + "\u00A0";
    private const int MaxTitleLength = 50;
    
    protected static string GetVariantName(string variant) => $"Gr. {variant}";

    private static string GetQuizTitle(string title) =>
        title.Length > MaxTitleLength ? title[..MaxTitleLength] + "..." : title;

    private static string GetQuizTitle(string title, string variant) =>
        $"{GetQuizTitle(title)} - {GetVariantName(variant)}";

    protected static string GetQuizTitle(ExportTestVariant variant, bool multipleVariants = false) =>
        multipleVariants ? GetQuizTitle(variant.TestName, variant.Variant.ToString()) : GetQuizTitle(variant.TestName);
}