import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_models.dart';
import 'app_config.dart';

class QuizApi {
  // ===== OPERACJE NA QUIZACH =====
  
  static Future<List<QuizDto>> getQuizSets() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/quiz'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => QuizDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quizzes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<QuizDetailDto> getQuizSet(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/quiz/$id'));
      
      if (response.statusCode == 200) {
        return QuizDetailDto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load quiz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<QuizDetailDto> createQuiz(QuizGeneratorOptions options) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(options.toJson()),
      );

      if (response.statusCode == 200) {
        return QuizDetailDto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create quiz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<QuizDetailDto> editQuiz(String id, Quiz quiz) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/quiz/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(quiz.toJson()),
      );

      if (response.statusCode == 200) {
        return QuizDetailDto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to edit quiz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> deleteQuiz(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/quiz/$id'));
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ===== OPERACJE NA LOGACH =====
  
  static Future<List<QuizLogDto>> getLogs() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/logs'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => QuizLogDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<QuizLogDetailDto> getLogById(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/logs/$id'));
      
      if (response.statusCode == 200) {
        return QuizLogDetailDto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ===== POZOSTAŁE =====

  static Future<List<String>> getGptModels() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/gpt/models'));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List<dynamic>)
            .map((item) => item['name'] as String)
            .toList();
      } else {
        throw Exception('Failed to load GPT models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ===== METODY POMOCNICZE - FILTROWANIE LOGÓW =====
  
  static Future<List<QuizLogDto>> getLogsForQuiz(String quizId) async {
    try {
      final allLogs = await getLogs();
      return allLogs.where((log) => log.quizId == quizId).toList();
    } catch (e) {
      throw Exception('Failed to load quiz logs: $e');
    }
  }

  // ===== EKSPORT  =====
  
  static String buildExportUrl(
    String format, // 'pdf' lub 'docx'
    String quizId, {
    int? questionCount,
    int variantsCount = 1,
    String layout = 'standard',
    bool includeAnswerKey = true,
  }) {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Export/$format/$quizId');
    final queryParams = <String, String>{
      'layout': layout,
      'includeAnswerKey': includeAnswerKey.toString(),
      'variantsCount': variantsCount.toString(),
    };
    
    if (questionCount != null) {
      queryParams['questionCount'] = questionCount.toString();
    }
    
    return uri.replace(queryParameters: queryParams).toString();
  }
}