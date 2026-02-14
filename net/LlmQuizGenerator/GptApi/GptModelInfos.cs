using System.Text.Json;
using System.Text.RegularExpressions;
using LlmQuizGenerator.Models;
using OpenAI.Chat;

namespace LlmQuizGenerator.GptApi;

public static class GptModelInfos
{
    private const decimal UsdToPlnFallback = 3.60m;

    public static IReadOnlyList<GptModelInfo> ModelInfos { get; } =
    [
        new("gpt-4o", 2.5m, 10.0m),
        new("gpt-4o-mini", 0.15m, 0.60m),
        
        new("gpt-4.1", 2.00m, 8.00m),
        new("gpt-4.1-mini", 0.40m, 1.60m),
        new("gpt-4.1-nano", 0.10m, 0.40m),

        new("gpt-5.2", 1.75m, 14.00m),
        new("gpt-5.1", 1.25m, 10.00m),
        
        //Domyślny reasoning
        new("gpt-5", 1.25m, 10.00m),
        new("gpt-5-mini", 0.25m, 2.00m),
        new("gpt-5-nano", 0.05m, 0.40m),
    ];

    public const string DefaultModelName = "gpt-4o";

    public static async Task<UsageInfo?> UsageInfoAsync(string modelName, ChatTokenUsage usage)
    {
        var model = GetModelByName(modelName);
        if (model == null) return null;
    
        var usdToPln = await UsdToPlnAsync();
    
        var inputPrice = usage.InputTokenCount * model.InputTokenPrice;
        var outputPrice = usage.OutputTokenCount * model.OutputTokenPrice;
        var totalPrice = inputPrice + outputPrice;
    
        return new UsageInfo(
            ModelName: modelName,
            Input1MTokenPriceUsd: model.Input1MTokenPrice,
            Output1MTokenPriceUsd: model.Output1MTokenPrice,
            InputTokenPriceUsd: model.InputTokenPrice,
            OutputTokenPriceUsd: model.OutputTokenPrice,
            InputTokenCount: usage.InputTokenCount,
            OutputTokenCount: usage.OutputTokenCount,
            InputPriceUsd: inputPrice,
            OutputPriceUsd: outputPrice,
            TotalPriceUsd: totalPrice,
            EstimatedTotalPricePlnGr: totalPrice * usdToPln * 100
        );
    }

    private static GptModelInfo? GetModelByName(string name)
    {
        var match = Regex.Match(name, @"^(.*?)(?:-\d{4}-\d{2}-\d{2})?$");
        if(match.Success) name = match.Groups[1].Value;
        
        return ModelInfos.SingleOrDefault(info => info.Name == name);
    }

    public static bool ModelExists(string? modelName)
    {
        return ModelInfos.Any(info => info.Name == modelName);
    }
    
    private static async Task<decimal> UsdToPlnAsync() => await _usdToPlnTask.Value;
    
    private static readonly Lazy<Task<decimal>> _usdToPlnTask = new(async () =>
    {
        try
        {
            using var httpClient = new HttpClient();
            httpClient.Timeout = TimeSpan.FromSeconds(5);
            
            var response = await httpClient.GetStringAsync(
                "http://api.nbp.pl/api/exchangerates/rates/a/usd/last/1/?format=json");
            
            var json = JsonSerializer.Deserialize<JsonElement>(response);
            return json.GetProperty("rates")[0].GetProperty("mid").GetDecimal();
        }
        catch
        {
            return UsdToPlnFallback;  // FALLBACK
        }
    });
    
}

public record GptModelInfo(string Name, decimal Input1MTokenPrice, decimal Output1MTokenPrice)
{
    public decimal InputTokenPrice { get; } = Input1MTokenPrice / 1E6m;
    public decimal OutputTokenPrice { get; } = (Output1MTokenPrice / 1E6m);
}