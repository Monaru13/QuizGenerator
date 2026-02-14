using System.Text.Json;
using LlmQuizGenerator.Generation;
using LlmQuizGenerator.Models;
using OpenAI.Chat;

namespace LlmQuizGenerator.GptApi;

internal class GptQuizGenerator(LlmQuizGeneratorConfiguration configuration) : IGptQuizGenerator
{
    private readonly string _defaultModelName = configuration.DefaultModel ?? GptModelInfos.DefaultModelName;

    public async Task<LlmQuizResult> GenerateQuizAsync(QuizGeneratorOptions options)
    {
        var chatClient = CreateChatClient(options.ModelName);
        
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        ChatMessage[] messages = [
            DeveloperMessageFactory.CreateDeveloperMessage(options),
            new UserChatMessage(options.Topic)
        ];
        
        var completionOptions = new ChatCompletionOptions
        {
            MaxOutputTokenCount = configuration.MaxOutputTokenCountPerQuestion * options.QuestionCount,
            ResponseFormat = ChatResponseFormatFactory.CreateSingleChoiceQuizFormat(options.AnswerVariants),
        };
        
        ChatCompletion completion = await chatClient.CompleteChatAsync(messages, completionOptions);

        var responseQuiz =  JsonSerializer.Deserialize<ResponseQuiz>(completion.Content[0].Text) ??
            throw new InvalidOperationException();
        
        return new LlmQuizResult(
            responseQuiz,
            new
            {
                Request = new
                {
                    ChatMessages = messages,
                    ChatCompletionOptions = completionOptions,
                    ResponseSchema = JsonSerializer.Deserialize<JsonElement>(ChatResponseFormatFactory.CreateSingleChoiceQuizSchema(options.AnswerVariants).ToString())
                },
                Response = new
                {
                    ChatCompletion = completion,
                }
            },
            await GptModelInfos.UsageInfoAsync(completion.Model, completion.Usage),
            stopwatch.Elapsed);
    }

    private ChatClient CreateChatClient(string? modelName)
    {
        return new ChatClient(
            GptModelInfos.ModelExists(modelName) ? modelName : _defaultModelName, 
            configuration.ApiKey);
    }
}