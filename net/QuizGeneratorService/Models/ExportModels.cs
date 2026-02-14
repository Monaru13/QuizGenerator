namespace QuizGeneratorService.Models;

/// <summary>
/// Parametry eksportu testu
/// </summary>
public record ExportParameters
{
    /// <summary>
    /// ID quizu do eksportu
    /// </summary>
    public Guid QuizId { get; init; }
    
    /// <summary>
    /// Format eksportu (PDF/DOCX)
    /// </summary>
    public ExportFormat Format { get; init; } = ExportFormat.PDF;
    
    /// <summary>
    /// Layout dokumentu
    /// </summary>
    public ExportLayout Layout { get; init; } = ExportLayout.Standard;
    
    /// <summary>
    /// Liczba pytań do wyeksportowania (null = wszystkie)
    /// </summary>
    public int? QuestionCount { get; init; }
    
    /// <summary>
    /// Liczba wariantów testu do wygenerowania
    /// </summary>
    public int VariantsCount { get; init; } = 1;
    
    /// <summary>
    /// Czy dołączyć klucz odpowiedzi
    /// </summary>
    public bool IncludeAnswerKey { get; init; } = true;
    
    /// <summary>
    /// Czy randomizować kolejność pytań
    /// </summary>
    public bool ShuffleQuestions { get; init; } = true;
    
    /// <summary>
    /// Czy randomizować kolejność odpowiedzi
    /// </summary>
    public bool ShuffleAnswers { get; init; } = true;
    
    /// <summary>
    /// Seed dla randomizacji (dla powtarzalności)
    /// </summary>
    public int? RandomSeed { get; init; }
    
    /// <summary>
    /// Czy minimalizować łamanie stron (pytania nie przechodzą na następną stronę)
    /// </summary>
    public bool PreventQuestionSplit { get; init; } = true;
}

/// <summary>
/// Wynik eksportu
/// </summary>
public record ExportResult
{
    /// <summary>
    /// Wygenerowany plik (bajty)
    /// </summary>
    public byte[] FileData { get; init; } = Array.Empty<byte>();
    
    /// <summary>
    /// Nazwa pliku
    /// </summary>
    public string FileName { get; init; } = string.Empty;
    
    /// <summary>
    /// MIME type pliku
    /// </summary>
    public string ContentType { get; init; } = string.Empty;
    
    /// <summary>
    /// Liczba wygenerowanych pytań
    /// </summary>
    public int GeneratedQuestionsCount { get; init; }
    
    /// <summary>
    /// Liczba wygenerowanych wariantów
    /// </summary>
    public int GeneratedVariantsCount { get; init; }
    
    /// <summary>
    /// Czas generowania
    /// </summary>
    public TimeSpan GenerationTime { get; init; }
}

/// <summary>
/// Model reprezentujący przygotowane pytanie do eksportu
/// </summary>
public record ExportQuestion
{
    /// <summary>
    /// Numer pytania
    /// </summary>
    public int Number { get; init; }
    
    /// <summary>
    /// Treść pytania
    /// </summary>
    public string Text { get; init; } = string.Empty;
    
    /// <summary>
    /// Lista odpowiedzi (w kolejności do wyświetlenia)
    /// </summary>
    public List<ExportAnswer> Answers { get; init; } = new();
    
    /// <summary>
    /// Index poprawnej odpowiedzi (po przemieszaniu)
    /// </summary>
    public int CorrectAnswerIndex { get; init; }
}

/// <summary>
/// Model reprezentujący odpowiedź do eksportu
/// </summary>
public record ExportAnswer
{
    /// <summary>
    /// Litera odpowiedzi (a, b, c, d)
    /// </summary>
    public char Letter { get; init; }
    
    /// <summary>
    /// Treść odpowiedzi
    /// </summary>
    public string Text { get; init; } = string.Empty;
    
    /// <summary>
    /// Czy to jest poprawna odpowiedź
    /// </summary>
    public bool IsCorrect { get; init; }
}

/// <summary>
/// Model reprezentujący wariant testu
/// </summary>
public record ExportTestVariant
{
    /// <summary>
    /// Wariant testu (A, B, C, D)
    /// </summary>
    public TestVariant Variant { get; init; }
    
    /// <summary>
    /// Nazwa testu
    /// </summary>
    public string TestName { get; init; } = string.Empty;
    
    /// <summary>
    /// Lista pytań w tym wariancie
    /// </summary>
    public List<ExportQuestion> Questions { get; init; } = new();
    
    /// <summary>
    /// Data wygenerowania
    /// </summary>
    public DateTime GeneratedAt { get; init; } = DateTime.Now;
}

/// <summary>
/// Wynik walidacji parametrów eksportu
/// </summary>
public record ValidationResult
{
    /// <summary>
    /// Czy walidacja zakończona sukcesem
    /// </summary>
    public bool IsValid { get; init; }
    
    /// <summary>
    /// Lista błędów walidacji
    /// </summary>
    public List<string> Errors { get; init; } = new();
}