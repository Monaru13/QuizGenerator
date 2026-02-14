using LlmQuizGenerator.Generation;
using LlmQuizGenerator.GptApi;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace QuizGeneratorService.Endpoints;

public class QuizOptionsSchemaExample : ISchemaFilter
{
    public void Apply(OpenApiSchema schema, SchemaFilterContext context)
    {
        if (context.Type == typeof(QuizGeneratorOptions))
        {
            schema.Example = new Microsoft.OpenApi.Any.OpenApiObject
            {
                ["topic"] = new Microsoft.OpenApi.Any.OpenApiString("Lotnictwo na ogół nie obejmuje zagadnień związanych z lotami w kosmos, którymi zajmuje się astronautyka. Istnieją jednak lub zaproponowane zostały systemy, gdzie lot orbitalny lub suborbitalny, czy nawet opuszczenie strefy grawitacji Ziemi lotem międzyplanetarnym, jest do wykonania pojazdem kosmicznym startującym ze specjalnie przystosowanego samolotu wzniesionego na wysoki pułap lotu, gdzie energetyczny koszt rozpoczęcia lotu kosmicznego, i (co za tym idzie) potrzebna masa pojazdu z potrzebnym paliwem jest znacznie zmniejszona w porównaniu ze startem za pomocą wielkiej rakiety odpalonej z powierzchni."),
                ["questionCount"] = new Microsoft.OpenApi.Any.OpenApiInteger(5),
                ["difficultyLevel"] = new Microsoft.OpenApi.Any.OpenApiString(QuizDifficultyLevel.Medium.ToString()),
                ["answerVariants"] = new Microsoft.OpenApi.Any.OpenApiInteger(4),
                ["modelName"] = new Microsoft.OpenApi.Any.OpenApiString(GptModelInfos.DefaultModelName),
            };
        }
    }
}