import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_api.dart';
import '../widgets/info_row.dart';
import '../widgets/info_row_with_chip.dart';

class QuizEditScreen extends StatefulWidget {
  final QuizDetailDto quiz;

  const QuizEditScreen({super.key, required this.quiz});

  @override
  _QuizEditScreenState createState() => _QuizEditScreenState();
}

class _QuizEditScreenState extends State<QuizEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<QuestionEditor> _questionEditors;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.quiz.name);
    _questionEditors = widget.quiz.questions?.map((q) => 
      QuestionEditor.fromQuestion(q)
    ).toList() ?? [];
    
    if (_questionEditors.isEmpty) {
      _addNewQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edytuj quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isSaving ? null : _saveQuiz,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Informacje o quizie
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Informacje o quizie',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 8),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nazwa quizu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nazwa jest wymagana';
                        }
                        return null;
                      },
                    ),

                    if (widget.quiz.options != null) ...[
                      const SizedBox(height: 12),
                      InfoRowWithChip(
                        label: 'Poziom trudności:',
                        value: widget.quiz.options!.difficultyLevel.displayName,
                        color: widget.quiz.options!.difficultyLevel.color,
                        icon: widget.quiz.options!.difficultyLevel.icon,
                      ),
                      if (widget.quiz.options!.topic != null) ...[
                        const SizedBox(height: 8),
                        InfoRow(
                          label: 'Temat:',
                          value: widget.quiz.options!.topic!,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Pytania
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.quiz, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Pytania (${_questionEditors.length})',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _addNewQuestion,
                          icon: Icon(Icons.add),
                          label: Text('Dodaj pytanie'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 8),
                    
                    ..._questionEditors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final editor = entry.value;
                      return _buildQuestionEditor(index, editor);
                    }),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Przycisk zapisu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveQuiz,
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Zapisywanie...' : 'Zapisz zmiany',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionEditor(int index, QuestionEditor editor) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Pytanie ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _addAnswer(editor),
                      tooltip: 'Dodaj odpowiedź',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: _questionEditors.length > 1 
                          ? () => _removeQuestion(index)
                          : null,
                      tooltip: 'Usuń pytanie',
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            TextFormField(
              controller: editor.questionController,
              decoration: InputDecoration(
                labelText: 'Treść pytania',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.help_outline),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Treść pytania jest wymagana';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  'Odpowiedzi (zaznacz poprawną):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),

            ...editor.answerControllers.asMap().entries.map((answerEntry) {
              final answerIndex = answerEntry.key;
              final answerController = answerEntry.value;
              final isCorrect = editor.correctAnswerIndex == answerIndex;

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.grey.shade300,
                    width: isCorrect ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: answerIndex,
                      groupValue: editor.correctAnswerIndex,
                      onChanged: (value) {
                        setState(() {
                          editor.correctAnswerIndex = value!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: answerController,
                        decoration: InputDecoration(
                          labelText: 'Odpowiedź ${String.fromCharCode(65 + answerIndex)}',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          suffixIcon: editor.answerControllers.length > 2
                              ? IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _removeAnswer(editor, answerIndex),
                                  tooltip: 'Usuń odpowiedź',
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Odpowiedź nie może być pusta';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (isCorrect)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'POPRAWNA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            if (editor.correctAnswerIndex == -1)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade800),
                    SizedBox(width: 8),
                    Text(
                      'Wybierz poprawną odpowiedź',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addNewQuestion() {
    setState(() {
      _questionEditors.add(QuestionEditor());
    });
  }

  void _removeQuestion(int index) {
    if (_questionEditors.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz musi mieć przynajmniej jedno pytanie')),
      );
      return;
    }

    setState(() {
      _questionEditors[index].dispose();
      _questionEditors.removeAt(index);
    });
  }

  void _addAnswer(QuestionEditor editor) {
    if (editor.answerControllers.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maksymalnie 6 odpowiedzi na pytanie')),
      );
      return;
    }

    setState(() {
      editor.answerControllers.add(TextEditingController());
    });
  }

  void _removeAnswer(QuestionEditor editor, int answerIndex) {
    if (editor.answerControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pytanie musi mieć przynajmniej 2 odpowiedzi')),
      );
      return;
    }

    setState(() {
      editor.answerControllers[answerIndex].dispose();
      editor.answerControllers.removeAt(answerIndex);
      
      if (editor.correctAnswerIndex == answerIndex) {
        editor.correctAnswerIndex = -1;
      } else if (editor.correctAnswerIndex > answerIndex) {
        editor.correctAnswerIndex--;
      }
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Sprawdź czy wszystkie pytania mają zaznaczoną poprawną odpowiedź
    for (int i = 0; i < _questionEditors.length; i++) {
      if (_questionEditors[i].correctAnswerIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pytanie ${i + 1} nie ma zaznaczonej poprawnej odpowiedzi'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final questions = _questionEditors.map((editor) {
        return QuizQuestion(
          text: editor.questionController.text.trim(),
          answers: editor.answerControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return QuizAnswer(
              text: controller.text.trim(),
              isCorrect: index == editor.correctAnswerIndex,
            );
          }).toList(),
        );
      }).toList();

      final updatedQuiz = Quiz(
        id: widget.quiz.id,
        name: _nameController.text.trim(),
        questions: questions,
        options: widget.quiz.options,
        createdAt: widget.quiz.createdAt,
      );

      await QuizApi.editQuiz(widget.quiz.id, updatedQuiz);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz został zaktualizowany!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd zapisywania: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final editor in _questionEditors) {
      editor.dispose();
    }
    super.dispose();
  }
}

class QuestionEditor {
  late TextEditingController questionController;
  late List<TextEditingController> answerControllers;
  int correctAnswerIndex = -1;

  QuestionEditor() {
    questionController = TextEditingController();
    answerControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
  }

  QuestionEditor.fromQuestion(QuizQuestion question) {
    questionController = TextEditingController(text: question.text);
    answerControllers = question.answers?.map((answer) => 
      TextEditingController(text: answer.text)
    ).toList() ?? [];
    correctAnswerIndex = question.answers?.indexWhere((answer) => answer.isCorrect) ?? -1;
    
    // Zapewnij minimum 2 odpowiedzi
    while (answerControllers.length < 2) {
      answerControllers.add(TextEditingController());
    }
  }

  void dispose() {
    questionController.dispose();
    for (final controller in answerControllers) {
      controller.dispose();
    }
  }
}