using Microsoft.OpenApi.Models;
using LlmQuizGenerator;
using LlmQuizGenerator.Models;
using QuizGeneratorService.Endpoints;
using QuizGeneratorService.Extensions;

var builder = WebApplication.CreateBuilder(args);

var quizOptions = builder.Configuration.GetSection("QuizGenerator").Get<LlmQuizGeneratorConfiguration>()
                  ?? throw new InvalidOperationException("QuizGenerator section missing!");

builder.Services
    // Rejestracja serwisów w DI
    .AddQuizGeneratorService(quizOptions)
    .AddTestExportServices()
    // CORS (dev - zezwala wszystko)
    .AddCors(options =>
    {
        options.AddDefaultPolicy(policy =>
        {
            policy.AllowAnyOrigin() // http://localhost:49680 (Flutter web)
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
    })
    // Konfiguracja Swagger
    .AddEndpointsApiExplorer()
    .AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new OpenApiInfo
        {
            Title = "Quiz Generator API",
            Version = "v1",
            Description = """
                          API do generowania testów jednokrotnego wyboru za pomocą AI.
                          [All quiz sets](/api/quiz)
                          [All logs](/api/logs)
                          """,
        });

        c.SchemaFilter<QuizOptionsSchemaExample>();
    });


var app = builder.Build();

// 3️⃣ Włączamy Swagger UI
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.MapEndpoints();

app.Run();