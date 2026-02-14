using LlmQuizGenerator.Generation;
using OpenAI.Chat;

namespace LlmQuizGenerator.GptApi;

public static class DeveloperMessageFactory
{
    public static DeveloperChatMessage CreateDeveloperMessage(QuizGeneratorOptions options)
    {
        return new DeveloperChatMessage(
            $"""
                 **Twoim zadaniem jest stworzenie testu jednokrotnego wyboru na podstawie podanego tekstu.**  
                 **Użytkownik poda wyłącznie treść zagadnienia – nie podaje liczby pytań.**  
                 
                 - **Liczba pytań:** {options.QuestionCount}.  
                 - **Źródło:** Wszystkie pytania muszą dotyczyć **wyłącznie informacji zawartych w podanym tekście**.  
                 - **Format odpowiedzi:** Każde pytanie ma mieć **{options.AnswerVariants} warianty odpowiedzi**:
                     - ✅ **Jedna poprawna odpowiedź** – musi być **ściśle zawarta w tekście, ale nie musi być cycatem**.
                     - ❌ **Trzy błędne odpowiedzi** – mogą **nawiązywać do tematu**, ale nie muszą być zawarte w tekscie.  
                 - **Nie dodawaj wyjaśnień, komentarzy ani dodatkowych informacji.**
                 - **W treści pytania nie nawiązuj do analizy tekstu np: "Czy wg tekstu..." - osoba egzaminowana nie zna i nie widzi tego tekstu**  
             
                 **Użytkownik poda tylko tekst do analizy.**  
                 **Generuj dokładnie {options.QuestionCount} pytań i zwróć wyłącznie JSON.**
                 **Dostosuj trudność pytań w 3 stopniowej skali (1-3) na {(int)options.DifficultyLevel} - {options.DifficultyLevel}**
             """);
    }
}