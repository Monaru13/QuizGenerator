import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_api.dart';
import 'log_details_screen.dart';
import 'quiz_details_screen.dart';

class LogsListScreen extends StatefulWidget {
  final String? quizId;

  const LogsListScreen({super.key, this.quizId});

  @override
  _LogsListScreenState createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> with TickerProviderStateMixin {
  late Future<List<QuizLogDto>> _logsFuture;
  late TabController _tabController;
  String _sortBy = 'date'; // 'date', 'price', 'time', 'difficulty'
  bool _sortAscending = false;
  String _filterBy = 'all'; // 'all', 'easy', 'medium', 'hard'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshLogs() {
    setState(() {
      if (widget.quizId != null) {
        _logsFuture = QuizApi.getLogsForQuiz(widget.quizId!);
      } else {
        _logsFuture = QuizApi.getLogs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizId != null ? 'Logi quizu' : 'Wszystkie logi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshLogs,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value.startsWith('sort_')) {
                  _sortBy = value.substring(5);
                  _sortAscending = !_sortAscending;
                } else if (value.startsWith('filter_')) {
                  _filterBy = value.substring(7);
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort_date',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('Sortuj po dacie'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_price',
                child: Row(
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(width: 8),
                    Text('Sortuj po cenie'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_time',
                child: Row(
                  children: [
                    Icon(Icons.timer),
                    SizedBox(width: 8),
                    Text('Sortuj po czasie generowania'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'filter_all',
                child: Text('Wszystkie poziomy'),
              ),
              PopupMenuItem(
                value: 'filter_easy',
                child: Text('Tylko łatwe'),
              ),
              PopupMenuItem(
                value: 'filter_medium',
                child: Text('Tylko średnie'),
              ),
              PopupMenuItem(
                value: 'filter_hard',
                child: Text('Tylko trudne'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.analytics), text: 'Statystyki'),
            Tab(icon: Icon(Icons.timeline), text: 'Oś czasu'),
          ],
        ),
      ),
      body: FutureBuilder<List<QuizLogDto>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          var logs = _filterAndSortLogs(snapshot.data!);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildLogsList(logs),
              _buildStatisticsView(logs),
              _buildTimelineView(logs),
            ],
          );
        },
      ),
    );
  }

  List<QuizLogDto> _filterAndSortLogs(List<QuizLogDto> logs) {
    // Filtrowanie
    var filteredLogs = logs;
    if (_filterBy != 'all') {
      filteredLogs = logs.where((log) {
        switch (_filterBy) {
          case 'easy':
            return log.difficultyLevel == QuizDifficultyLevel.easy;
          case 'medium':
            return log.difficultyLevel == QuizDifficultyLevel.medium;
          case 'hard':
            return log.difficultyLevel == QuizDifficultyLevel.hard;
          default:
            return true;
        }
      }).toList();
    }

    // Sortowanie
    filteredLogs.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'price':
          comparison = a.totalPriceUsd.compareTo(b.totalPriceUsd);
          break;
        case 'time':
          comparison = a.timeSpan.compareTo(b.timeSpan);
          break;
        case 'difficulty':
          comparison = a.difficultyLevel.value.compareTo(b.difficultyLevel.value);
          break;
        case 'date':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filteredLogs;
  }

  Widget _buildLogsList(List<QuizLogDto> logs) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildEnhancedLogCard(log, index);
      },
    );
  }

  Widget _buildEnhancedLogCard(QuizLogDto log, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _openLogDetails(log.quizId),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header z nazwą i poziomem trudności
              Row(
                children: [
                  Expanded(
                    child: Text(
                      log.name ?? 'Quiz ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDifficultyChip(log.difficultyLevel),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Informacje o quizie
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text('${log.questionCount} pytań'),
                  SizedBox(width: 16),
                  Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text('${log.answerVariants} odpowiedzi'),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Informacje o czasie i kosztach
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          log.formattedTimeSpan,
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        log.formattedPricePln,
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Model i data
              Row(
                children: [
                  if (log.modelName != null) ...[
                    Icon(Icons.smart_toy, size: 16, color: Colors.purple),
                    SizedBox(width: 4),
                    Text(
                      log.modelName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    SizedBox(width: 16),
                  ],
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    _formatDateTime(log.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.open_in_new, size: 20),
                    onPressed: () => _openQuizDetails(log.quizId),
                    tooltip: 'Otwórz quiz',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(QuizDifficultyLevel difficulty) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: difficulty.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: difficulty.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(difficulty.icon, size: 16, color: difficulty.color),
          SizedBox(width: 4),
          Text(
            difficulty.displayName,
            style: TextStyle(
              color: difficulty.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView(List<QuizLogDto> logs) {
    if (logs.isEmpty) return _buildEmptyState();

    final totalCost = logs.fold<double>(0, (sum, log) => sum + log.estimatedTotalPricePlnGr);
    final avgCost = totalCost / logs.length;
    final totalQuestions = logs.fold<int>(0, (sum, log) => sum + log.questionCount);
    
    final difficultyStats = <QuizDifficultyLevel, int>{};
    for (final difficulty in QuizDifficultyLevel.values) {
      difficultyStats[difficulty] = logs.where((log) => log.difficultyLevel == difficulty).length;
    }

    final modelStats = <String, int>{};
    for (final log in logs) {
      if (log.modelName != null) {
        modelStats[log.modelName!] = (modelStats[log.modelName!] ?? 0) + 1;
      }
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Ogólne statystyki
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ogólne statystyki',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildStatRow('Łączna liczba quizów:', logs.length.toString()),
                _buildStatRow('Łączna liczba pytań:', totalQuestions.toString()),
                _buildStatRow('Łączny koszt:', '${(totalCost / 100).toStringAsFixed(2)} zł'),
                _buildStatRow('Średni koszt na quiz:', '${(avgCost / 100).toStringAsFixed(2)} zł'),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Statystyki poziomów trudności
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Poziomy trudności',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...difficultyStats.entries.map((entry) => 
                  _buildStatRowWithIcon(
                    '${entry.key.displayName}:', 
                    entry.value.toString(),
                    entry.key.icon,
                    entry.key.color,
                  )
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Statystyki modeli AI
        if (modelStats.isNotEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wykorzystane modele AI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...modelStats.entries.map((entry) => 
                    _buildStatRow('${entry.key}:', entry.value.toString())
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineView(List<QuizLogDto> logs) {
    if (logs.isEmpty) return _buildEmptyState();

    // Sortuj logi chronologicznie
    final sortedLogs = List<QuizLogDto>.from(logs);
    sortedLogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedLogs.length,
      itemBuilder: (context, index) {
        final log = sortedLogs[index];
        final isFirst = index == 0;
        final isLast = index == sortedLogs.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line
            Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.blue.shade300,
                  ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: log.difficultyLevel.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    log.difficultyLevel.icon,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.blue.shade300,
                  ),
              ],
            ),
            
            SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.name ?? 'Quiz ${index + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDateTime(log.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('${log.questionCount} pytań'),
                              SizedBox(width: 16),
                              Text(log.formattedTimeSpan),
                              SizedBox(width: 16),
                              Text(log.formattedPricePln),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast) SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatRowWithIcon(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
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
            onPressed: _refreshLogs,
            child: Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(widget.quizId != null 
              ? 'Brak logów dla tego quizu' 
              : 'Brak logów generowania'),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _openLogDetails(String quizId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogDetailsScreen(quizId: quizId),
      ),
    );
  }

  void _openQuizDetails(String quizId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDetailsScreen(quizId: quizId),
      ),
    );
  }
}