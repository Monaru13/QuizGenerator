using System.Text.Json.Serialization;

namespace LlmQuizGenerator.Models;

public record ResponseQuiz(
    [property: JsonPropertyName("n")] string Name,
    [property: JsonPropertyName("q")] List<ResponseQuizQuestion> Questions
);

public record ResponseQuizQuestion(
    [property: JsonPropertyName("t")] string Text,
    [property: JsonPropertyName("c")] string Correct,
    [property: JsonPropertyName("w1")] string Wrong1,
    [property: JsonPropertyName("w2")] string Wrong2,
    [property: JsonPropertyName("w3")] string Wrong3,
    [property: JsonPropertyName("w4")] string Wrong4,
    [property: JsonPropertyName("w5")] string Wrong5
);