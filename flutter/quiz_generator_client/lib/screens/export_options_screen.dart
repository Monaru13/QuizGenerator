import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/file_download_service.dart';

class ExportOptionsScreen extends StatefulWidget {
  final QuizDetailDto quiz;

  const ExportOptionsScreen({super.key, required this.quiz});

  @override
  _ExportOptionsScreenState createState() => _ExportOptionsScreenState();
}

class _ExportOptionsScreenState extends State<ExportOptionsScreen> {
  String _selectedLayout = 'Standard';
  bool _includeAnswerKey = true;
  String _selectedFormat = 'pdf';
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  int? _customQuestionCount;
  int _variantsCount = 1;
  bool _useCustomQuestionCount = false;

  late TextEditingController _questionCountController;
  late TextEditingController _variantsCountController;

  final Map<String, String> _layoutOptions = {
    'Standard': 'Standardowy',
    'Compact': 'Kompaktowy',
    'Double': 'Podwójny (2 egzemplarze)',
    'Economic': 'Ekonomiczny',
  };

  final Map<String, String> _layoutDescriptions = {
    'Standard': 'Jeden quiz na stronę, standardowe czcionki',
    'Compact': 'Oszczędność papieru, mniejsze czcionki',
    'Double': 'Dwa warianty quizu obok siebie',
    'Economic': 'Maksymanie upakowany - minimalne marginesy, małe czcionki',
  };

  @override
  void initState() {
    super.initState();
    _variantsCount = 4;
    _questionCountController = TextEditingController(
      text: widget.quiz.questions?.length.toString() ?? '5'
    );
    _variantsCountController = TextEditingController(
      text: _variantsCount.toString()
    );
  }

  @override
  void dispose() {
    _questionCountController.dispose();
    _variantsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eksport quizu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Informacje o quizie
          _buildQuizInfoCard(),
          SizedBox(height: 16),

          // Wybór formatu
          //_buildFormatSelectionCard(),
          //SizedBox(height: 16),

          // NOWA SEKCJA - Parametry eksportu
          _buildExportParametersCard(),
          SizedBox(height: 16),

          // Wybór layoutu
          _buildLayoutSelectionCard(),
          SizedBox(height: 16),

          // Opcje dodatkowe
          _buildAdditionalOptionsCard(),
          SizedBox(height: 24),

          // Progress bar podczas pobierania
          if (_isDownloading) ...[
            _buildProgressCard(),
            SizedBox(height: 16),
          ],

          // Przyciski akcji
          _buildActionButtons(),
          SizedBox(height: 16),

          // Informacje o layoutach
          _buildLayoutInfoCard(),
        ],
      ),
    );
  }

  Widget _buildQuizInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz do eksportu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildInfoRow('Nazwa:', widget.quiz.name ?? "Bez nazwy"),
            _buildInfoRow('Pytań:', '${widget.quiz.questions?.length ?? 0}'),
            _buildInfoRow('Poziom:', widget.quiz.options?.difficultyLevel.displayName ?? 'Nieznany'),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelectionCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Format pliku',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            RadioListTile<String>(
              title: Text('PDF'),
              subtitle: Text('Uniwersalny format, łatwy do druku'),
              value: 'pdf',
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            ),

            RadioListTile<String>(
              title: Text('DOCX (Word)'),
              subtitle: Text('Edytowalny dokument Microsoft Word'),
              value: 'docx',
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportParametersCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parametry eksportu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            SizedBox(height: 8),
            TextFormField(
              controller: _questionCountController,
              decoration: InputDecoration(
                labelText: 'Liczba pytań do eksportu',
                border: OutlineInputBorder(),
                helperText: 'Maksymalnie: ${widget.quiz.questions?.length ?? 0}',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => {
                _useCustomQuestionCount = true,
                _customQuestionCount = int.tryParse(value)},
            ),

            SizedBox(height: 16),

            // Poziome przyciski dla wariantów
            Text('Liczba wariantów testu', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 1, label: Text('1')),
                  ButtonSegment(value: 2, label: Text('2')),
                  ButtonSegment(value: 3, label: Text('3')),
                  ButtonSegment(value: 4, label: Text('4')),
                ],
                selected: {_variantsCount},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _variantsCount = newSelection.first;
                    _variantsCountController.text = _variantsCount.toString();
                  });
                },
              ),
            ),
            Text('Ile różnych zestawów odpowiedzi wygenerować',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutSelectionCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layout strony',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            ..._layoutOptions.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                subtitle: Text(_layoutDescriptions[entry.key] ?? ''),
                value: entry.key,
                groupValue: _selectedLayout,
                onChanged: (value) {
                  setState(() {
                    _selectedLayout = value!;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opcje dodatkowe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            SwitchListTile(
              title: Text('Dołącz klucz odpowiedzi'),
              subtitle: Text('Poprawne odpowiedzi na końcu dokumentu'),
              value: _includeAnswerKey,
              onChanged: (value) {
                setState(() {
                  _includeAnswerKey = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Pobieranie...'),
            SizedBox(height: 8),
            LinearProgressIndicator(value: _downloadProgress),
            SizedBox(height: 8),
            Text('${(_downloadProgress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isDownloading ? null : _downloadFile,
            icon: Icon(_isDownloading ? Icons.downloading : Icons.download),
            label: Text(_isDownloading ? 'Pobieranie...' : 'Pobierz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutInfoCard() {
    return Card(
      color: Colors.blue.shade50,
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
                  'Informacje o parametrach',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '• Liczba pytań: Możesz wyeksportować mniej pytań niż jest w quizie\n'
              '• Warianty odpowiedzi: Różne zestawy odpowiedzi dla tego samego testu\n'
              '• Standardowy: Najlepszy dla normalnego druku\n'
              '• Kompaktowy: Oszczędza papier, mniejsze czcionki\n'
              '• Podwójny: Dwa egzemplarze na jednej stronie\n'
              '• Ekonomiczny: Maksymalna oszczędność papieru',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _downloadFile() async {
    // Walidacja danych
    if (_useCustomQuestionCount) {
      final maxQuestions = widget.quiz.questions?.length ?? 0;
      final questionCount = int.tryParse(_questionCountController.text) ?? 0;
      
      if (questionCount <= 0 || questionCount > maxQuestions) {
        _showErrorDialog('Liczba pytań musi być między 1 a $maxQuestions');
        return;
      }
      _customQuestionCount = questionCount;
    }

    if (_variantsCount <= 0 || _variantsCount > 4) {
      _showErrorDialog('Liczba wariantów odpowiedzi musi być między 1 a 4');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      String? filePath;
      
      void onProgress(int received, int total) {
        setState(() {
          _downloadProgress = received / total;
        });
      }

      filePath = await FileDownloadService.downloadPdf(
        widget.quiz.id,
        quizName: widget.quiz.name ?? "Quiz",
        questionCount: _useCustomQuestionCount ? _customQuestionCount : null,
        variantsCount: _variantsCount,
        layout: _selectedLayout,
        includeAnswerKey: _includeAnswerKey,
        onProgress: onProgress,
      );

      if (filePath != null) {
        _showSuccessDialog(filePath);
      } else {
        _showErrorDialog('Nie udało się pobrać pliku');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pobrano pomyślnie'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plik został zapisany w:'),
            SizedBox(height: 8),
            SelectableText(
              filePath,
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Zamknij'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FileDownloadService.openFile(filePath);
              } catch (e) {
                _showErrorDialog('Nie można otworzyć pliku: $e');
              }
            },
            child: Text('Otwórz plik'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Błąd'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}