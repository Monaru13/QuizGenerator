using OpenAI.Chat;

namespace LlmQuizGenerator.GptApi;

public static class ChatResponseFormatFactory
{
    private const string SingleChoiceQuizSchemaName = "single_choice_quiz_schema";
    private const string MultipleChoiceQuizSchemaName = "multiple_choice_quiz_schema";
    private const string OpenEndedQuizSchemaName = "open_ended_quiz_schema";
    private const string TrueFalseQuizSchemaName = "true_false_quiz_schema";

    public static ChatResponseFormat CreateSingleChoiceQuizFormat(int answerVariants)
    {
        return ChatResponseFormat.CreateJsonSchemaFormat(
            SingleChoiceQuizSchemaName,
            CreateSingleChoiceQuizSchema(answerVariants), 
            null,
            true);
    }

    public static BinaryData CreateSingleChoiceQuizSchema(int answerVariants)
    {
        if (answerVariants < 2) throw new ArgumentException("answerVariants must be >= 2");

        var wrongAnswerCount = answerVariants - 1;

        // Generowanie dynamicznych błędnych odpowiedzi
        var wrongAnswers = string.Join(",\n", 
            Enumerable.Range(1, wrongAnswerCount)
                .Select(i => $"          \"w{i}\": {{ \"type\": \"string\", \"description\": \"Błędna odpowiedź {i}\" }}"));

        // Generowanie dynamicznej tablicy "required"
        var requiredFields = string.Join(", ", 
            Enumerable.Range(1, wrongAnswerCount)
                .Select(i => $"\"w{i}\""));

        return BinaryData.FromString(
          $$"""
            {
              "type": "object",
              "properties": {
                "n": { "type": "string", "description": "Nazwa quizu" },
                "q": {
                  "type": "array",
                  "description": "Lista pytań w quizie",
                  "items": {
                    "type": "object",
                    "properties": {
                      "t": { "type": "string", "description": "Treść pytania" },
                      "c": { "type": "string", "description": "Poprawna odpowiedź" },
                       {{wrongAnswers}}
                    },
                    "required": [ "t", "c", {{requiredFields}} ],
                    "additionalProperties": false
                  }
                }
              },
              "required": [ "n", "q" ],
              "additionalProperties": false
            }
            """
        );
    }
}