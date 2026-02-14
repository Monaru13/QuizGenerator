import 'package:flutter/material.dart';
import '../models/quiz_models.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizDetailDto quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  _QuizPlayScreenState createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _showResults = false;
  late List<QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.quiz.questions ?? [];
    _questions.shuffle();

    for (var question in _questions) {
      question.answers?.shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Brak pytań w tym quizie'),
            ],
          ),
        ),
      );
    }

    if (_showResults) {
      return _buildResultsScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];
    final answers = question.answers ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.name ?? "Quiz"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress bar z dodatkowymi informacjami
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pytanie ${_currentQuestionIndex + 1} z ${_questions.length}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (widget.quiz.options != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.quiz.options!.difficultyLevel.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: widget.quiz.options!.difficultyLevel.color),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.quiz.options!.difficultyLevel.icon,
                              size: 14,
                              color: widget.quiz.options!.difficultyLevel.color,
                            ),
                            SizedBox(width: 4),
                            Text(
                              widget.quiz.options!.difficultyLevel.displayName,
                              style: TextStyle(
                                color: widget.quiz.options!.difficultyLevel.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pytanie
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.help_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Pytanie:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            question.text ?? 'Brak tekstu pytania',
                            style: TextStyle(fontSize: 18, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Wybierz odpowiedź:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Odpowiedzi
                  Expanded(
                    child: ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final answer = answers[index];
                        final isSelected = _selectedAnswers[_currentQuestionIndex] == index;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 3 : 1,
                          color: isSelected ? Colors.blue.shade50 : null,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              setState(() {
                                _selectedAnswers[_currentQuestionIndex] = index;
                              });
                              if (_currentQuestionIndex < _questions.length - 1) {
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey,
                                        width: 2,
                                      ),
                                      color: isSelected ? Colors.blue : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check, size: 16, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      answer.text ?? 'Brak tekstu odpowiedzi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                        color: isSelected ? Colors.blue.shade800 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nawigacja
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text('Poprzednie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  SizedBox(width: 120),

                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: _selectedAnswers[_currentQuestionIndex] != null
                        ? () {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          }
                        : null,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Następne'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _selectedAnswers[_currentQuestionIndex] != null
                        ? _finishQuiz
                        : null,
                    icon: Icon(Icons.check),
                    label: Text('Zakończ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    int correctAnswers = 0;
    int totalQuestions = _questions.length;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final selectedAnswerIndex = _selectedAnswers[i];
      if (selectedAnswerIndex != null) {
        final selectedAnswer = question.answers![selectedAnswerIndex];
        if (selectedAnswer.isCorrect) {
          correctAnswers++;
        }
      }
    }

    double percentage = (correctAnswers / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wyniki'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Podsumowanie wyników
          Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    percentage >= 80 
                        ? Icons.emoji_events 
                        : percentage >= 60 
                            ? Icons.thumb_up 
                            : Icons.sentiment_neutral,
                    size: 80,
                    color: percentage >= 80 
                        ? Colors.amber
                        : percentage >= 60 
                            ? Colors.green 
                            : Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _getResultMessage(percentage),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '$correctAnswers / $totalQuestions',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 24, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 16),
                  _buildResultBar(percentage),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Szczegóły odpowiedzi
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Szczegóły odpowiedzi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  ...List.generate(_questions.length, (index) {
                    final question = _questions[index];
                    final selectedAnswerIndex = _selectedAnswers[index];
                    final correctAnswerIndex = question.answers?.indexWhere((a) => a.isCorrect) ?? -1;
                    final isCorrect = selectedAnswerIndex == correctAnswerIndex;

                    return ExpansionTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text('Pytanie ${index + 1}'),
                      subtitle: Text(
                        question.text ?? 'Brak tekstu pytania',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedAnswerIndex != null) ...[
                                Text('Twoja odpowiedź:'),
                                Container(
                                  margin: EdgeInsets.only(left: 16, top: 4),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCorrect ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCorrect ? Icons.check_circle : Icons.cancel,
                                        color: isCorrect ? Colors.green : Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          question.answers![selectedAnswerIndex].text ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                              ],
                              
                              if (!isCorrect && correctAnswerIndex >= 0) ...[
                                Text('Poprawna odpowiedź:'),
                                Container(
                                  margin: EdgeInsets.only(left: 16, top: 4),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.lightbulb, color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          question.answers![correctAnswerIndex].text ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Przyciski akcji
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = 0;
                      _selectedAnswers.clear();
                      _showResults = false;
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Spróbuj ponownie'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.home),
                  label: Text('Zakończ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultBar(double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(fontSize: 12)),
            Text('100%', style: TextStyle(fontSize: 12)),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 80 
                  ? Colors.green 
                  : percentage >= 60 
                      ? Colors.orange 
                      : Colors.red,
            ),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  String _getResultMessage(double percentage) {
    if (percentage >= 90) {
      return 'Doskonały wynik! 🎉';
    } else if (percentage >= 80) {
      return 'Bardzo dobry wynik! 👏';
    } else if (percentage >= 70) {
      return 'Dobry wynik! 👍';
    } else if (percentage >= 60) {
      return 'Wynik do poprawy 📚';
    } else {
      return 'Spróbuj jeszcze raz 💪';
    }
  }

  void _finishQuiz() {
    setState(() {
      _showResults = true;
    });
  }
}