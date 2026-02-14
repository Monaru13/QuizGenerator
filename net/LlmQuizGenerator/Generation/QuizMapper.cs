using LlmQuizGenerator.Models;

namespace LlmQuizGenerator.Generation;

internal static class QuizMapper
{
    public static Quiz MapResponseQuizToQuiz(ResponseQuiz responseQuiz, QuizGeneratorOptions options, Guid? id = null)
    {
        return new Quiz(
            Id: id ?? Guid.NewGuid(),
            Name: responseQuiz.Name,
            Questions: responseQuiz.Questions
                .Select(q => new QuizQuestion(
                    q.Text,
                    new QuizAnswer[]
                        {
                            new(q.Correct, true),
                            new(q.Wrong1, false),
                            new(q.Wrong2, false),
                            new(q.Wrong3, false),
                            new(q.Wrong4, false),
                            new(q.Wrong5, false),
                        }
                        .Where(x => !string.IsNullOrEmpty(x.Text))
                        .ToArray()
                ))
                .ToArray(),
            Options: options
        );
    }
}