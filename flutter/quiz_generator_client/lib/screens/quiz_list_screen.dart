import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/app_config.dart';
import '../services/quiz_api.dart';
import 'quiz_creator_screen.dart';
import 'quiz_details_screen.dart';
import 'logs_list_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late Future<List<QuizDto>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _refreshQuizzes();
  }

  void _refreshQuizzes() {
    setState(() {
      _quizzesFuture = QuizApi.getQuizSets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizy'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (showLogs)
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogsListScreen(), // Wszystkie logi
                  ),
                );
              },
              tooltip: 'Zobacz wszystkie logi',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshQuizzes,
          ),
        ],
      ),
      body: FutureBuilder<List<QuizDto>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Błąd: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshQuizzes,
                    child: Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Brak quizów. Stwórz pierwszy!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final quiz = snapshot.data![index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: quiz.difficultyLevel.color,
                    child: Icon(
                      quiz.difficultyLevel.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    quiz.name ?? 'Bez nazwy',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pytań: ${quiz.questionCount} • Odpowiedzi: ${quiz.answerVariants}'),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          _buildDifficultyChip(quiz.difficultyLevel),
                          SizedBox(width: 8),
                          Text(
                            _formatDateTime(quiz.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        _deleteQuiz(quiz.id);
                      } else if (value == 'logs') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogsListScreen(quizId: quiz.id),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      if (showLogs)
                        PopupMenuItem(
                          value: 'logs',
                          child: ListTile(
                            leading: Icon(Icons.history, color: Colors.blue),
                            title: Text('Zobacz logi'),
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Usuń'),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizDetailsScreen(quizId: quiz.id),
                      ),
                    ).then((_) => _refreshQuizzes());
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizCreatorScreen()),
          ).then((result) {
            if (result != null) {
              _refreshQuizzes();
              // Przejdź do szczegółów nowo utworzonego quizu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizDetailsScreen(quizId: result.id),
                ),
              );
            }
          });
        },
        label: Text('Nowy quiz'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDifficultyChip(QuizDifficultyLevel difficulty) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: difficulty.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: difficulty.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(difficulty.icon, size: 12, color: difficulty.color),
          SizedBox(width: 2),
          Text(
            difficulty.displayName,
            style: TextStyle(
              color: difficulty.color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  Future<void> _deleteQuiz(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usuń quiz'),
        content: Text('Czy na pewno chcesz usunąć ten quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await QuizApi.deleteQuiz(id);
                _refreshQuizzes();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quiz został usunięty'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Błąd usuwania: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Usuń', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}