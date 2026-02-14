using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LlmQuizGenerator.Data;

public class QuizSetEntity
{
    [Key]
    public Guid Id { get; set; }

    [Column(TypeName = "TEXT")]
    public string JsonData { get; set; } = "";
}