using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using QuizGeneratorService.Models;

namespace QuizGeneratorService.Services.Generators;

/// <summary>
/// Generator dokumentów PDF
/// </summary>
public class PdfGenerator : BaseDocumentGenerator, IDocumentGenerator<Document>
{
    public string ContentType => "application/pdf";
    public string FileExtension => ".pdf";
    
    static PdfGenerator()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }
    
    public Document Generate(
        List<ExportTestVariant> variants,
        ExportParameters parameters)
    {
        return parameters.Layout switch
        {
            ExportLayout.Compact => GenerateCompactPdf(variants, parameters),
            ExportLayout.Double => GenerateDoublePdf(variants, parameters),
            ExportLayout.Economic => GenerateEconomicPdf(variants, parameters),
            _ => GenerateStandardPdf(variants, parameters)
        };
    }
    
    /// <summary>
    /// Standard PDF - duże marginesy, czytelny
    /// </summary>
    private static Document GenerateStandardPdf(List<ExportTestVariant> variants, ExportParameters parameters)
    {
        return Document.Create(container =>
        {
            foreach (var variant in variants)
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(12).FontFamily(Fonts.Arial));

                    page.Header()
                        .Text(GetQuizTitle(variant, variants.Count > 1))
                        .SemiBold()
                        .FontSize(18)
                        .FontColor(Colors.Blue.Medium)
                        .AlignCenter();

                    page.Content()
                        .PaddingVertical(1, Unit.Centimetre)
                        .Column(x =>
                        {
                            x.Spacing(15);
                            
                            // Informacje o teście
                            x.Item().Row(row =>
                            {
                                row.RelativeItem().Text(NamePlaceholder);
                                row.RelativeItem().Text(DatePlaceholder).AlignRight();
                            });
                            x.Item().LineHorizontal(1);
                            
                            // Pytania
                            foreach (var question in variant.Questions)
                            {
                                var question1 = question;
                                x.Item().Column(col =>
                                {
                                    col.Item().Text($"{question1.Number}. {question1.Text}")
                                        .FontSize(12)
                                        .SemiBold();
                                    
                                    col.Item().PaddingTop(5);
                                    
                                    // Odpowiedzi
                                    foreach (var answer in question1.Answers)
                                    {
                                        col.Item().Row(answerRow =>
                                        {
                                            answerRow.ConstantItem(20).Text($"{answer.Letter})");
                                            answerRow.ConstantItem(15).Text("☐");
                                            answerRow.RelativeItem().Text(answer.Text ?? "");
                                        });
                                    }
                                    
                                    col.Item().PaddingTop(10);
                                });
                            }
                        });
                });
            }
            
            GenerateAnswerKeyPage(variants, parameters, container);
        });
    }

    /// <summary>
    /// Compact PDF - zoptymalizowane marginesy i fonty
    /// </summary>
    private static Document GenerateCompactPdf(List<ExportTestVariant> variants, ExportParameters parameters)
    {
        return Document.Create(container =>
        {
            foreach (var variant in variants)
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(1.5f, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(10).FontFamily(Fonts.Arial));

                    page.Header()
                        .Text(GetQuizTitle(variant, variants.Count > 1))
                        .SemiBold()
                        .FontSize(14)
                        .FontColor(Colors.Blue.Medium)
                        .AlignCenter();

                    page.Content()
                        .PaddingVertical(0.5f, Unit.Centimetre)
                        .Column(x =>
                        {
                            x.Spacing(8);

                            x.Item().Row(row =>
                            {
                                row.RelativeItem().Text(NamePlaceholder).FontSize(9);
                                row.RelativeItem().Text(DatePlaceholder).AlignRight().FontSize(9);
                            });
                            x.Item().LineHorizontal(1);
                            
                            // Pytania w kompaktowym formacie
                            foreach (var question in variant.Questions)
                            {
                                x.Item().Column(col =>
                                {
                                    col.Item().Text($"{question.Number}. {question.Text}")
                                        .FontSize(10)
                                        .SemiBold();
                                    
                                    // Odpowiedzi poziomo jeśli krótkie
                                    if (question.Answers.All(a => (a.Text?.Length ?? 0) <= 30))
                                    {
                                        col.Item().Row(answerRow =>
                                        {
                                            foreach (var answer in question.Answers)
                                            {
                                                answerRow.RelativeItem().Row(singleAnswer =>
                                                {
                                                    singleAnswer.ConstantItem(15).Text($"{answer.Letter})");
                                                    singleAnswer.ConstantItem(10).Text("☐");
                                                    singleAnswer.RelativeItem().Text(answer.Text ?? "").FontSize(9);
                                                });
                                            }
                                        });
                                    }
                                    else
                                    {
                                        // Odpowiedzi pionowo
                                        foreach (var answer in question.Answers)
                                        {
                                            col.Item().Row(answerRow =>
                                            {
                                                answerRow.ConstantItem(15).Text($"{answer.Letter})");
                                                answerRow.ConstantItem(10).Text("☐");
                                                answerRow.RelativeItem().Text(answer.Text ?? "").FontSize(9);
                                            });
                                        }
                                    }
                                    
                                    col.Item().PaddingTop(5);
                                });
                            }
                        });
                });
            }
            
            GenerateAnswerKeyPage(variants, parameters, container);
        });
    }

    /// <summary>
    /// Double PDF - dwa testy obok siebie
    /// </summary>
    private static Document GenerateDoublePdf(List<ExportTestVariant> variants, ExportParameters parameters)
    {
        return Document.Create(container =>
        {
            var multipleVariants = variants.Count > 1;
            
            // Grupuj warianty po 2
            for (var i = 0; i < variants.Count; i += 2)
            {
                var leftVariant = variants[i];
                var rightVariant = i + 1 < variants.Count ? variants[i + 1] : null;
                
                container.Page(page =>
                {
                    page.Size(PageSizes.A4.Landscape());
                    page.Margin(1, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(9).FontFamily(Fonts.Arial));

                    page.Content()
                        .Column(x =>
                        {
                            x.Spacing(10);
                            
                            // Dwa quizy obok siebie
                            x.Item().Row(row =>
                            {
                                // Lewy quiz
                                row.RelativeItem().Border(1).Padding(5).Column(leftCol =>
                                {
                                    GenerateQuizContent(leftCol, leftVariant, GetQuizTitle(leftVariant, multipleVariants));
                                });
                                
                                row.ConstantItem(10);

                                // Prawy quiz
                                if (rightVariant != null)
                                {
                                    row.RelativeItem().Border(1).Padding(5).Column(rightCol =>
                                    {
                                        GenerateQuizContent(rightCol, rightVariant, GetQuizTitle(rightVariant, multipleVariants));
                                    });
                                }
                                else
                                {
                                    row.RelativeItem(); // Pusta przestrzeń
                                }
                            });
                        });
                });
            }
            
            GenerateAnswerKeyPage(variants, parameters, container);
        });
    }

    /// <summary>
    /// Economic PDF - maksymalne wykorzystanie papieru
    /// </summary>
    private static Document GenerateEconomicPdf(List<ExportTestVariant> variants, ExportParameters parameters)
    {
        return Document.Create(container =>
        {
            foreach (var variant in variants)
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(0.8f, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(9).FontFamily(Fonts.Arial));

                    page.Header()
                        .Text(GetQuizTitle(variant, variants.Count > 1))
                        .SemiBold()
                        .FontSize(12)
                        .AlignCenter();

                    page.Content()
                        .Column(x =>
                        {
                            x.Spacing(5);

                            x.Item().Row(row =>
                            {
                                row.RelativeItem().Text(NamePlaceholder).FontSize(8);
                                row.RelativeItem().Text(DatePlaceholder).AlignRight().FontSize(8);
                            });
                            x.Item().LineHorizontal(0.5f);
                            
                            // Pytania w bardzo kompaktowym formacie
                            foreach (var question in variant.Questions)
                            {
                                x.Item().Column(col =>
                                {
                                    col.Item().Text($"{question.Number}. {question.Text}")
                                        .FontSize(9)
                                        .SemiBold();
                                    
                                    // Inteligentne rozmieszczenie odpowiedzi
                                    if (question.Answers.Count <= 4 && question.Answers.All(a => (a.Text?.Length ?? 0) <= 25))
                                    {
                                        // 2x2 grid dla krótkich odpowiedzi
                                        col.Item().Row(topRow =>
                                        {
                                            for (var j = 0; j < Math.Min(2, question.Answers.Count); j++)
                                            {
                                                var answer = question.Answers[j];
                                                topRow.RelativeItem().Row(ar =>
                                                {
                                                    ar.ConstantItem(12).Text($"{answer.Letter})").FontSize(8);
                                                    ar.ConstantItem(8).Text("☐").FontSize(8);
                                                    ar.RelativeItem().Text(answer.Text ?? "").FontSize(8);
                                                });
                                            }
                                        });
                                        
                                        if (question.Answers.Count > 2)
                                        {
                                            col.Item().Row(bottomRow =>
                                            {
                                                for (var j = 2; j < question.Answers.Count; j++)
                                                {
                                                    var answer = question.Answers[j];
                                                    bottomRow.RelativeItem().Row(ar =>
                                                    {
                                                        ar.ConstantItem(12).Text($"{answer.Letter})").FontSize(8);
                                                        ar.ConstantItem(8).Text("☐").FontSize(8);
                                                        ar.RelativeItem().Text(answer.Text ?? "").FontSize(8);
                                                    });
                                                }
                                            });
                                        }
                                    }
                                    else
                                    {
                                        // Standardowo pionowo
                                        foreach (var answer in question.Answers)
                                        {
                                            col.Item().Row(answerRow =>
                                            {
                                                answerRow.ConstantItem(12).Text($"{answer.Letter})").FontSize(8);
                                                answerRow.ConstantItem(8).Text("☐").FontSize(8);
                                                answerRow.RelativeItem().Text(answer.Text ?? "").FontSize(8);
                                            });
                                        }
                                    }
                                    
                                    col.Item().PaddingTop(3);
                                });
                            }
                        });
                });
            }
            
            GenerateAnswerKeyPage(variants, parameters, container);
        });
    }

    /// <summary>
    /// Pomocnicza metoda do generowania zawartości quizu (dla double layout)
    /// </summary>
    private static void GenerateQuizContent(ColumnDescriptor column, ExportTestVariant variant, string title)
    {
        column.Item().Text(title)
            .SemiBold()
            .FontSize(10)
            .AlignCenter();
        
        column.Item().Row(row =>
        {
            row.RelativeItem().Text(NamePlaceholder).FontSize(8);
            row.RelativeItem().Text(DatePlaceholder).AlignRight().FontSize(8);
        });
        
        column.Item().LineHorizontal(0.5f);
        column.Item().Padding(2);
        
        foreach (var question in variant.Questions)
        {
            column.Item().Column(col =>
            {
                col.Item().Text($"{question.Number}. {question.Text}")
                    .FontSize(8)
                    .SemiBold();
                
                foreach (var answer in question.Answers)
                {
                    col.Item().Row(answerRow =>
                    {
                        answerRow.ConstantItem(12).Text($"{answer.Letter})").FontSize(7);
                        answerRow.ConstantItem(8).Text("☐").FontSize(7);
                        answerRow.RelativeItem().Text(answer.Text ?? "").FontSize(7);
                    });
                }
                
                col.Item().PaddingTop(3);
            });
        }
    }

    private static void GenerateAnswerKeyPage(List<ExportTestVariant> variants, ExportParameters parameters, IDocumentContainer container)
    {
        if (!parameters.IncludeAnswerKey) 
            return;
        
        var variantAnswerKeys = variants.Select((v, idx) => new 
        { 
            Name = GetVariantName(v.Variant.ToString()),
            Keys = v.Questions
                .Select(q => $"{q.Number}. {q.Answers[q.CorrectAnswerIndex].Letter}")
                .Select(key => key.Replace(" ", "\u00A0"))
                .ToList()
        }).ToList();
                
        container.Page(page =>
        {
            page.Size(PageSizes.A4);
            page.Margin(2, Unit.Centimetre);
            page.DefaultTextStyle(x => x.FontSize(12).FontFamily(Fonts.Arial));
        
            page.Content()
                .Column(x =>
                {
                    x.Item().Text($"{GetQuizTitle(variants[0])} - Klucz odp.")
                        .FontSize(12)
                        .SemiBold()
                        .AlignCenter();
                    x.Item().LineHorizontal(2);
                    x.Item().PaddingTop(15);
                
                    foreach (var vInfo in variantAnswerKeys)
                    {
                        // Nagłówek wariantu
                        x.Item().PaddingBottom(8).Text(vInfo.Name)
                            .FontSize(12)
                            .SemiBold();
                                
                        x.Item().Text(string.Join("    ", vInfo.Keys))
                            .FontSize(11);

                        x.Item().PaddingVertical(10).LineHorizontal(1);
                    }
                });
        });
    }

    public byte[] ConvertToBytes(Document document)
    {
        return document.GeneratePdf();
    }
}