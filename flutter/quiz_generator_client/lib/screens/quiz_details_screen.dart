import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/app_config.dart';
import '../services/quiz_api.dart';
import '../widgets/info_row.dart';
import '../widgets/info_row_with_chip.dart';
import 'quiz_play_screen.dart';
import 'quiz_edit_screen.dart';
import 'logs_list_screen.dart';
import 'export_options_screen.dart';

class QuizDetailsScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailsScreen({super.key, required this.quizId});

  @override
  _QuizDetailsScreenState createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {
  late Future<QuizDetailDto> _quizFuture;

  @override
  void initState() {
    super.initState();
    _refreshQuiz();
  }

  void _refreshQuiz() {
    setState(() {
      _quizFuture = QuizApi.getQuizSet(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuizDetailDto>(
        future: _quizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text('Ładowanie...')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text('Błąd')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Błąd: ${snapshot.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshQuiz,
                      child: Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              ),
            );
          }

          final quiz = snapshot.data!;
          final questions = quiz.questions ?? [];

          return Scaffold(
            appBar: AppBar(
              title: Text(quiz.name ?? 'Quiz'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizEditScreen(quiz: quiz),
                        ),
                      ).then((_) => _refreshQuiz());
                    } else if (value == 'logs') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogsListScreen(quizId: quiz.id),
                        ),
                      );
                    } else if (value == 'export') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExportOptionsScreen(quiz: quiz),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'export',
                      child: ListTile(
                        leading: Icon(Icons.file_download, color: Colors.green),
                        title: Text('Eksportuj'),
                      ),
                    ),
                    if (showLogs)
                      PopupMenuItem(
                        value: 'logs',
                        child: ListTile(
                          leading: Icon(Icons.history, color: Colors.blue),
                          title: Text('Zobacz logi'),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edytuj'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: ListView(
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
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 8),
                        InfoRow(label: 'Nazwa:', value: quiz.name ?? 'Bez nazwy'),
                        InfoRow(label: 'Liczba pytań:', value: '${questions.length}'),
                        InfoRow(label: 'Data utworzenia:', value: _formatDateTime(quiz.createdAt)),
                        InfoRow(label: 'Model:', value: quiz.modelName ?? 'Brak modelu'),
                        InfoRow(label: 'Szacowana cena:', value: '${quiz.estimatedPricePln?.toStringAsFixed(3) ?? '0'} zł'),
                        InfoRow(label: 'Czas generowania:', value: quiz.formattedTimeSpan),

                        if (quiz.options != null) ...[
                          InfoRowWithChip(
                            label: 'Poziom trudności:',
                            value: quiz.options!.difficultyLevel.displayName,  // <-- dodaj jeśli potrzeba
                            color: quiz.options!.difficultyLevel.color,
                            icon: quiz.options!.difficultyLevel.icon,
                          ),
                          InfoRow(label: 'Warianty odpowiedzi:', value: '${quiz.options!.answerVariants}'),
                          if (quiz.options!.topic != null)
                            InfoRow(label: 'Temat:', value: quiz.options!.topic!),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Sekcja akcji
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Przycisk start
                        Column(
                          children: [
                            Icon(Icons.play_circle_filled, size: 64, color: Colors.green),
                            SizedBox(height: 12),
                            Text(
                              'Gotowy na wyzwanie?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: questions.isEmpty ? null : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizPlayScreen(quiz: quiz),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Rozpocznij quiz',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // SizedBox(height: 16),
                        
                        // Grid akcji
                        // GridView.count(
                        //   shrinkWrap: true,
                        //   physics: NeverScrollableScrollPhysics(),
                        //   crossAxisCount: 2,
                        //   mainAxisSpacing: 12,
                        //   crossAxisSpacing: 12,
                        //   childAspectRatio: 2.5,
                        //   children: [
                        //     // Przycisk eksport
                        //     // ElevatedButton.icon(
                        //     //   onPressed: () {
                        //     //     Navigator.push(
                        //     //       context,
                        //     //       MaterialPageRoute(
                        //     //         builder: (context) => ExportOptionsScreen(quiz: quiz),
                        //     //       ),
                        //     //     );
                        //     //   },
                        //     //   icon: Icon(Icons.file_download),
                        //     //   label: Text('Eksportuj'),
                        //     //   style: ElevatedButton.styleFrom(
                        //     //     backgroundColor: Colors.green,
                        //     //     foregroundColor: Colors.white,
                        //     //   ),
                        //     // ),
                        //
                        //     // Przycisk logi
                        //     // ElevatedButton.icon(
                        //     //   onPressed: () {
                        //     //     Navigator.push(
                        //     //       context,
                        //     //       MaterialPageRoute(
                        //     //         builder: (context) => LogsListScreen(quizId: quiz.id),
                        //     //       ),
                        //     //     );
                        //     //   },
                        //     //   icon: Icon(Icons.history),
                        //     //   label: Text('Logi'),
                        //     //   style: ElevatedButton.styleFrom(
                        //     //     backgroundColor: Colors.blue,
                        //     //     foregroundColor: Colors.white,
                        //     //   ),
                        //     // ),
                        //
                        //     // Przycisk edycja
                        //     // ElevatedButton.icon(
                        //     //   onPressed: () {
                        //     //     Navigator.push(
                        //     //       context,
                        //     //       MaterialPageRoute(
                        //     //         builder: (context) => QuizEditScreen(quiz: quiz),
                        //     //       ),
                        //     //     ).then((_) => _refreshQuiz());
                        //     //   },
                        //     //   icon: Icon(Icons.edit),
                        //     //   label: Text('Edytuj'),
                        //     //   style: ElevatedButton.styleFrom(
                        //     //     backgroundColor: Colors.orange,
                        //     //     foregroundColor: Colors.white,
                        //     //   ),
                        //     // ),
                        //
                        //     // // Przycisk udostępnij
                        //     // ElevatedButton.icon(
                        //     //   onPressed: () {
                        //     //     _showShareDialog(quiz);
                        //     //   },
                        //     //   icon: Icon(Icons.share),
                        //     //   label: Text('Udostępnij'),
                        //     //   style: ElevatedButton.styleFrom(
                        //     //     backgroundColor: Colors.purple,
                        //     //     foregroundColor: Colors.white,
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Podgląd pytań
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
                              'Podgląd pytań',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 8),
                        if (questions.isEmpty)
                          Text('Brak pytań w tym quizie.')
                        else
                          ...questions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final question = entry.value;
                            return ExpansionTile(
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
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _InfoRow_old(String label, String value) {
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Widget infoRow(String label, String value) {
  //   final bool isLong = value.length > 500;
  //   final String shortValue = value.length > 500 ? value.substring(0, 500) + '...' : value;
  //
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 4),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(
  //               width: 120,
  //               child: Text(
  //                 label,
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.grey.shade700,
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               child: Text(
  //                 shortValue,
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //             if (isLong)
  //               IconButton(
  //                 icon: Icon(Icons.expand_more),
  //                 onPressed: () {
  //                   // tu pokaż dialog/fullscreen z pełnym tekstem
  //                   showDialog(
  //                     context: context,
  //                     builder: (context) => AlertDialog(
  //                       title: Text(label),
  //                       content: SelectableText(value),  // pełny + selectable
  //                       actions: [
  //                         TextButton(
  //                           onPressed: () => Navigator.pop(context),
  //                           child: Text('Zamknij'),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _InfoRowWithChip(String label, String value, Color color, IconData icon) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         SizedBox(
  //           width: 120,
  //           child: Text(
  //             label,
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: Colors.grey.shade700,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.2),
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(color: color),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(icon, size: 16, color: color),
  //               SizedBox(width: 4),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   color: color,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showShareDialog(QuizDetailDto quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Udostępnij quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.link),
              title: Text('Skopiuj link'),
              onTap: () {
                // Implementacja kopiowania linku
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Link skopiowany do schowka')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('Kod QR'),
              onTap: () {
                Navigator.pop(context);
                // Implementacja generowania kodu QR
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anuluj'),
          ),
        ],
      ),
    );
  }
}