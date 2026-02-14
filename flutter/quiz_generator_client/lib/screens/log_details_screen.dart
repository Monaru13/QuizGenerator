import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz_models.dart';
import '../services/quiz_api.dart';
import 'quiz_details_screen.dart';

class LogDetailsScreen extends StatefulWidget {
  final String quizId;

  const LogDetailsScreen({super.key, required this.quizId});

  @override
  _LogDetailsScreenState createState() => _LogDetailsScreenState();
}

class _LogDetailsScreenState extends State<LogDetailsScreen> with TickerProviderStateMixin {
  late Future<QuizLogDetailDto> _logFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _logFuture = QuizApi.getLogById(widget.quizId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły logu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _logFuture = QuizApi.getLogById(widget.quizId);
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.info), text: 'Ogólne'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Response'),
            Tab(icon: Icon(Icons.analytics), text: 'Analiza'),
            Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
          ],
        ),
      ),
      body: FutureBuilder<QuizLogDetailDto>(
        future: _logFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final logDetail = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(logDetail),
              _buildAiResponseTab(logDetail.llmQuizResult?.responseQuiz),
              _buildAnalysisTab(logDetail.llmQuizResult?.usageInfo),
              _buildQuizTab(logDetail.quiz),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneralTab(QuizLogDetailDto logDetail) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Podstawowe informacje
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
                      'Podstawowe informacje',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 8),
                
                _buildInfoRow('ID quizu:', logDetail.quizId),
                _buildInfoRow('Nazwa:', logDetail.quiz?.name ?? 'Bez nazwy'),
                _buildInfoRow('Data utworzenia:', _formatDateTime(logDetail.createdAt)),
                
                if (logDetail.quiz?.options != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Parametry generowania:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow('Temat:', logDetail.quiz!.options!.topic ?? 'Brak tematu'),
                  _buildInfoRow('Liczba pytań:', '${logDetail.quiz!.options!.questionCount}'),
                  _buildInfoRowWithChip(
                    'Poziom trudności:', 
                    logDetail.quiz!.options!.difficultyLevel.displayName,
                    logDetail.quiz!.options!.difficultyLevel.color,
                    logDetail.quiz!.options!.difficultyLevel.icon,
                  ),
                  _buildInfoRow('Warianty odpowiedzi:', '${logDetail.quiz!.options!.answerVariants}'),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Czasowy breakdown
        if (logDetail.llmQuizResult != null)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Informacje czasowe',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  
                  _buildInfoRow('Czas generowania:', _formatTimeSpan(logDetail.llmQuizResult!.timeSpan)),
                  if (logDetail.llmQuizResult!.usageInfo != null)
                    _buildInfoRow('Model AI:', logDetail.llmQuizResult!.usageInfo!.modelName ?? 'Nieznany'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAiResponseTab(ResponseQuiz? responseQuiz) {
    if (responseQuiz == null) {
      return _buildNoDataState('Brak surowej odpowiedzi AI');
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.purple),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Surowa odpowiedź AI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(responseQuiz.toJson().toString()),
                      tooltip: 'Kopiuj JSON',
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 8),
                
                _buildInfoRow('Nazwa quizu:', responseQuiz.n ?? 'Brak nazwy'),
                _buildInfoRow('Liczba pytań:', '${responseQuiz.q?.length ?? 0}'),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Pytania z surowej odpowiedzi
        if (responseQuiz.q != null)
          ...responseQuiz.q!.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text('Pytanie ${index + 1}'),
                subtitle: Text(
                  question.t ?? 'Brak tekstu pytania',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pytanie:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(question.t ?? 'Brak tekstu'),
                        SizedBox(height: 12),
                        
                        Text(
                          'Odpowiedzi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        
                        ...question.getAllAnswers().asMap().entries.map((answerEntry) {
                          final answerIndex = answerEntry.key;
                          final answerText = answerEntry.value;
                          final isCorrect = answerText == question.c;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 4),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCorrect ? Colors.green : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isCorrect ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(child: Text(answerText)),
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAnalysisTab(UsageInfo? usageInfo) {
    if (usageInfo == null) {
      return _buildNoDataState('Brak informacji o wykorzystaniu AI');
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Koszt i tokeny
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Analiza kosztów',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 8),
                
                _buildInfoRow('Model AI:', usageInfo.modelName ?? 'Nieznany'),
                _buildInfoRow('Koszt całkowity (USD):', usageInfo.formattedTotalPrice),
                _buildInfoRow('Koszt całkowity (PLN):', usageInfo.formattedPricePln),
                
                SizedBox(height: 16),
                
                Text(
                  'Szczegóły tokenów:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                
                _buildInfoRow('Tokeny wejściowe:', usageInfo.formattedInputTokens),
                _buildInfoRow('Tokeny wyjściowe:', usageInfo.formattedOutputTokens),
                _buildInfoRow('Tokeny łącznie:', usageInfo.formattedTotalTokens),
                
                SizedBox(height: 16),
                
                Text(
                  'Ceny za tokeny:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                
                _buildInfoRow('Cena za 1M tokenów wejściowych:', '\$${usageInfo.input1MTokenPriceUsd.toStringAsFixed(2)}'),
                _buildInfoRow('Cena za 1M tokenów wyjściowych:', '\$${usageInfo.output1MTokenPriceUsd.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Wykres tokenów (wizualizacja)
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rozkład tokenów',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                _buildTokenBar(
                  'Tokeny wejściowe',
                  usageInfo.inputTokenCount,
                  usageInfo.inputTokenCount + usageInfo.outputTokenCount,
                  Colors.blue,
                ),
                SizedBox(height: 8),
                _buildTokenBar(
                  'Tokeny wyjściowe',
                  usageInfo.outputTokenCount,
                  usageInfo.inputTokenCount + usageInfo.outputTokenCount,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizTab(QuizDetailDto? quiz) {
    if (quiz == null) {
      return _buildNoDataState('Brak informacji o finalnym quizie');
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.quiz, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Finalny quiz',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 8),
                
                _buildInfoRow('ID:', quiz.id),
                _buildInfoRow('Nazwa:', quiz.name ?? 'Bez nazwy'),
                _buildInfoRow('Liczba pytań:', '${quiz.questions?.length ?? 0}'),
                _buildInfoRow('Data utworzenia:', _formatDateTime(quiz.createdAt)),
                
                SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizDetailsScreen(quizId: quiz.id),
                        ),
                      );
                    },
                    icon: Icon(Icons.open_in_new),
                    label: Text('Otwórz quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Preview pytań
        if (quiz.questions != null && quiz.questions!.isNotEmpty) ...[
          Text(
            'Podgląd pytań',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          
          ...quiz.questions!.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text('Pytanie ${index + 1}'),
                subtitle: Text(
                  question.text ?? 'Brak tekstu pytania',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pytanie:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(question.text ?? 'Brak tekstu pytania'),
                        SizedBox(height: 12),
                        Text(
                          'Odpowiedzi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...question.answers?.map((answer) => Padding(
                          padding: EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            children: [
                              Icon(
                                answer.isCorrect 
                                    ? Icons.check_circle 
                                    : Icons.radio_button_unchecked,
                                color: answer.isCorrect 
                                    ? Colors.green 
                                    : Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(answer.text ?? 'Brak tekstu odpowiedzi'),
                              ),
                            ],
                          ),
                        )).toList() ?? [],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTokenBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? value / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value (${(percentage * 100).toInt()}%)'),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithChip(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Błąd: $error'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _logFuture = QuizApi.getLogById(widget.quizId);
              });
            },
            child: Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatTimeSpan(String timeSpan) {
    final parts = timeSpan.split(':');
    if (parts.length >= 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = double.tryParse(parts[2]) ?? 0.0;
      
      if (hours > 0) {
        return '${hours}h ${minutes}min ${seconds.toInt()}s';
      } else if (minutes > 0) {
        return '${minutes}min ${seconds.toStringAsFixed(1)}s';
      } else {
        return '${seconds.toStringAsFixed(1)}s';
      }
    }
    return timeSpan;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Skopiowano do schowka')),
    );
  }
}