import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_api.dart';

class QuizCreatorScreen extends StatefulWidget {
  const QuizCreatorScreen({super.key});

  @override
  _QuizCreatorScreenState createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _questionCountController = TextEditingController(text: '5');
  final _answerVariantsController = TextEditingController(text: '4');

  QuizDifficultyLevel _selectedDifficulty = QuizDifficultyLevel.medium;
  bool _isGenerating = false;
  List<String> _gptModels = [];
  String? _selectedGptModel;
  bool _modelsLoaded = false;

  @override
  void dispose() {
    _topicController.dispose();
    _questionCountController.dispose();
    _answerVariantsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadGptModels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kreator quizu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Generator quizów AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Wygeneruj quiz na dowolny temat za pomocą sztucznej inteligencji',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Temat
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temat quizu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _topicController,
                      decoration: InputDecoration(
                        labelText: 'O czym ma być quiz?',
                        hintText: 'np. Historia Polski, Matematyka, Biologia...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.topic),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Temat jest wymagany';
                        }
                        if (value.trim().length < 5) {
                          return 'Temat musi mieć przynajmniej 5 znaków';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Parametry
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parametry quizu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    // Liczba pytań
                    TextFormField(
                      controller: _questionCountController,
                      decoration: InputDecoration(
                        labelText: 'Liczba pytań',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.quiz),
                        helperText: 'Od 1 do 50 pytań',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final count = int.tryParse(value ?? '');
                        if (count == null || count < 1 || count > 50) {
                          return 'Wprowadź liczbę od 1 do 50';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Liczba odpowiedzi
                    TextFormField(
                      controller: _answerVariantsController,
                      decoration: InputDecoration(
                        labelText: 'Liczba odpowiedzi na pytanie',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.list),
                        helperText: 'Od 2 do 6 odpowiedzi',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final count = int.tryParse(value ?? '');
                        if (count == null || count < 2 || count > 6) {
                          return 'Wprowadź liczbę od 2 do 6';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedGptModel,
                      decoration: InputDecoration(
                        labelText: 'Model GPT',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.smart_toy),
                        helperText: 'Wybierz model AI do generowania',
                      ),
                      items: _gptModels.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: _modelsLoaded
                          ? (String? value) => setState(() => _selectedGptModel = value)
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Poziom trudności
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poziom trudności',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),

                    ...QuizDifficultyLevel.values.map((difficulty) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedDifficulty == difficulty
                                ? difficulty.color
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: _selectedDifficulty == difficulty
                              ? difficulty.color.withOpacity(0.1)
                              : null,
                        ),
                        child: RadioListTile<QuizDifficultyLevel>(
                          title: Row(
                            children: [
                              Icon(
                                difficulty.icon,
                                color: difficulty.color,
                              ),
                              SizedBox(width: 8),
                              Text(
                                difficulty.displayName,
                                style: TextStyle(
                                  fontWeight: _selectedDifficulty == difficulty
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedDifficulty == difficulty
                                      ? difficulty.color
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(_getDifficultyDescription(difficulty)),
                          value: difficulty,
                          groupValue: _selectedDifficulty,
                          onChanged: (QuizDifficultyLevel? value) {
                            setState(() {
                              _selectedDifficulty = value!;
                            });
                          },
                          activeColor: difficulty.color,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Przycisk generowania
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateQuiz,
                icon: _isGenerating 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? 'Generowanie...' : 'Wygeneruj quiz',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            if (_isGenerating) ...[
              SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'AI generuje quiz...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        'To może potrwać kilka sekund',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 16),

            // Wskazówki
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Wskazówki',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Im bardziej szczegółowy temat, tym lepszy quiz\n'
                      '• Użyj konkretnych terminów i nazw\n'
                      '• Możesz podać zakres materiału (np. "Matematyka - równania kwadratowe")\n'
                      '• Poziom trudności wpływa na złożoność pytań',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyDescription(QuizDifficultyLevel difficulty) {
    switch (difficulty) {
      case QuizDifficultyLevel.easy:
        return 'Podstawowe pytania, proste odpowiedzi';
      case QuizDifficultyLevel.medium:
        return 'Pytania o średniej trudności';
      case QuizDifficultyLevel.hard:
        return 'Zaawansowane pytania wymagające głębszej wiedzy';
    }
  }

  Future<void> _generateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final options = QuizGeneratorOptions(
        topic: _topicController.text.trim(),
        questionCount: int.parse(_questionCountController.text),
        difficultyLevel: _selectedDifficulty,
        answerVariants: int.parse(_answerVariantsController.text),
        modelName: _selectedGptModel ?? 'gpt-4o',
      );

      final quiz = await QuizApi.createQuiz(options);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz został pomyślnie wygenerowany!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, quiz);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd generowania: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _loadGptModels() async {
    try {
      final models = await QuizApi.getGptModels();
      if (mounted) {
        setState(() {
          _gptModels = models;
          _selectedGptModel = models.isNotEmpty ? models.first : null;
          _modelsLoaded = true;
        });
      }
    } catch (e) {
      // fallback lub error
      if (mounted) setState(() => _modelsLoaded = true);
    }
  }

}