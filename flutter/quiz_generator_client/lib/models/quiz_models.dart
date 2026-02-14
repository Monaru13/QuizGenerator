import 'package:flutter/material.dart';

enum QuizDifficultyLevel {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const QuizDifficultyLevel(this.value);
  final String value;

  static QuizDifficultyLevel fromString(String value) {
    return QuizDifficultyLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => QuizDifficultyLevel.medium,
    );
  }

  String get displayName {
    switch (this) {
      case QuizDifficultyLevel.easy:
        return 'Łatwy';
      case QuizDifficultyLevel.medium:
        return 'Średni';
      case QuizDifficultyLevel.hard:
        return 'Trudny';
    }
  }

  IconData get icon {
    switch (this) {
      case QuizDifficultyLevel.easy:
        return Icons.sentiment_very_satisfied;
      case QuizDifficultyLevel.medium:
        return Icons.sentiment_neutral;
      case QuizDifficultyLevel.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color get color {
    switch (this) {
      case QuizDifficultyLevel.easy:
        return Colors.green;
      case QuizDifficultyLevel.medium:
        return Colors.orange;
      case QuizDifficultyLevel.hard:
        return Colors.red;
    }
  }
}

// QuizDto - dla listy quizów
class QuizDto {
  final String id;
  final String? name;
  final int questionCount;
  final int answerVariants;
  final QuizDifficultyLevel difficultyLevel;
  final DateTime createdAt;

  QuizDto({
    required this.id,
    this.name,
    required this.questionCount,
    required this.answerVariants,
    required this.difficultyLevel,
    required this.createdAt,
  });

  factory QuizDto.fromJson(Map<String, dynamic> json) {
    return QuizDto(
      id: json['id'],
      name: json['name'],
      questionCount: json['questionCount'] ?? 0,
      answerVariants: json['answerVariants'] ?? 0,
      difficultyLevel: QuizDifficultyLevel.fromString(json['difficultyLevel'] ?? 'Medium'),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'questionCount': questionCount,
      'answerVariants': answerVariants,
      'difficultyLevel': difficultyLevel.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// QuizDetailDto - dla szczegółów quizu
class QuizDetailDto {
  final String id;
  final String? name;
  final String? modelName;
  final double? estimatedPricePln;
  final String timeSpan;
  final List<QuizQuestion>? questions;
  final QuizGeneratorOptions? options;
  final DateTime createdAt;

  QuizDetailDto({
    required this.id,
    this.name,
    this.modelName,
    this.estimatedPricePln,
    required this.timeSpan,
    this.questions,
    this.options,
    required this.createdAt,
  });

  factory QuizDetailDto.fromJson(Map<String, dynamic> json) {
    return QuizDetailDto(
      id: json['id'],
      name: json['name'],
      modelName: json['modelName'],
      estimatedPricePln: json['estimatedPricePln']?.toDouble(),
      timeSpan: json['timeSpan'] ?? '00:00:00',
      questions: json['questions'] != null
          ? (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList()
          : null,
      options: json['options'] != null
          ? QuizGeneratorOptions.fromJson(json['options'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modelName': modelName,
      'estimatedPricePln': estimatedPricePln,
      'timeSpan': timeSpan,
      'questions': questions?.map((q) => q.toJson()).toList(),
      'options': options?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Formatowanie czasu generowania
  String get formattedTimeSpan {
    final parts = timeSpan.split(':');
    if (parts.length >= 3) {
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = double.tryParse(parts[2]) ?? 0.0;
      if (minutes > 0) {
        return '${minutes}min ${seconds.toInt()}s';
      } else {
        return '${seconds.toStringAsFixed(1)}s';
      }
    }
    return timeSpan;
  }
}


// Quiz - dla edycji
class Quiz {
  final String? id;
  final String? name;
  final List<QuizQuestion>? questions;
  final QuizGeneratorOptions? options;
  final DateTime? createdAt;

  Quiz({
    this.id,
    this.name,
    this.questions,
    this.options,
    this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      name: json['name'],
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
          : null,
      options: json['options'] != null
          ? QuizGeneratorOptions.fromJson(json['options'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'questions': questions?.map((q) => q.toJson()).toList(),
      'options': options?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class QuizQuestion {
  final String? text;
  final List<QuizAnswer>? answers;

  QuizQuestion({this.text, this.answers});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      text: json['text'],
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((a) => QuizAnswer.fromJson(a))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'answers': answers?.map((a) => a.toJson()).toList(),
    };
  }
}

class QuizAnswer {
  final String? text;
  final bool isCorrect;

  QuizAnswer({this.text, required this.isCorrect});

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      text: json['text'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class QuizGeneratorOptions {
  final String? topic;
  final int questionCount;
  final QuizDifficultyLevel difficultyLevel;
  final int answerVariants;
  final String? modelName;

  QuizGeneratorOptions({
    this.topic,
    required this.questionCount,
    required this.difficultyLevel,
    required this.answerVariants,
    this.modelName,
  });

  factory QuizGeneratorOptions.fromJson(Map<String, dynamic> json) {
    return QuizGeneratorOptions(
      topic: json['topic'],
      questionCount: json['questionCount'] ?? 5,
      difficultyLevel: QuizDifficultyLevel.fromString(json['difficultyLevel'] ?? 'Medium'),
      answerVariants: json['answerVariants'] ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'questionCount': questionCount,
      'difficultyLevel': difficultyLevel.value,
      'answerVariants': answerVariants,
      if (modelName != null) 'modelName': modelName,
    };
  }
}

// ===== MODELE LOGÓW =====

class QuizLogDto {
  final String quizId;
  final String? name;
  final int questionCount;
  final int answerVariants;
  final QuizDifficultyLevel difficultyLevel;
  final String timeSpan; // format: "00:01:23.456"
  final String? modelName;
  final double totalPriceUsd;
  final double estimatedTotalPricePlnGr;
  final DateTime createdAt;

  QuizLogDto({
    required this.quizId,
    this.name,
    required this.questionCount,
    required this.answerVariants,
    required this.difficultyLevel,
    required this.timeSpan,
    this.modelName,
    required this.totalPriceUsd,
    required this.estimatedTotalPricePlnGr,
    required this.createdAt,
  });

  factory QuizLogDto.fromJson(Map<String, dynamic> json) {
    return QuizLogDto(
      quizId: json['quizId'],
      name: json['name'],
      questionCount: json['questionCount'] ?? 0,
      answerVariants: json['answerVariants'] ?? 0,
      difficultyLevel: QuizDifficultyLevel.fromString(json['difficultyLevel'] ?? 'Medium'),
      timeSpan: json['timeSpan'] ?? '00:00:00',
      modelName: json['modelName'],
      totalPriceUsd: (json['totalPriceUsd'] ?? 0.0).toDouble(),
      estimatedTotalPricePlnGr: (json['estimatedTotalPricePlnGr'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'name': name,
      'questionCount': questionCount,
      'answerVariants': answerVariants,
      'difficultyLevel': difficultyLevel.value,
      'timeSpan': timeSpan,
      'modelName': modelName,
      'totalPriceUsd': totalPriceUsd,
      'estimatedTotalPricePlnGr': estimatedTotalPricePlnGr,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Formatowanie czasu generowania
  String get formattedTimeSpan {
    final parts = timeSpan.split(':');
    if (parts.length >= 3) {
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = double.tryParse(parts[2]) ?? 0.0;
      if (minutes > 0) {
        return '${minutes}min ${seconds.toInt()}s';
      } else {
        return '${seconds.toStringAsFixed(1)}s';
      }
    }
    return timeSpan;
  }

  // Formatowanie ceny w groszach PLN
  String get formattedPricePln {
    return '${(estimatedTotalPricePlnGr / 100).toStringAsFixed(2)} zł';
  }

  // Formatowanie ceny USD
  String get formattedPriceUsd {
    return '\$${totalPriceUsd.toStringAsFixed(4)}';
  }
}

class QuizLogDetailDto {
  final String quizId;
  final LlmQuizResult? llmQuizResult;
  final QuizDetailDto? quiz;
  final DateTime createdAt;

  QuizLogDetailDto({
    required this.quizId,
    this.llmQuizResult,
    this.quiz,
    required this.createdAt,
  });

  factory QuizLogDetailDto.fromJson(Map<String, dynamic> json) {
    return QuizLogDetailDto(
      quizId: json['quizId'],
      llmQuizResult: json['llmQuizResult'] != null
          ? LlmQuizResult.fromJson(json['llmQuizResult'])
          : null,
      quiz: json['quiz'] != null
          ? QuizDetailDto.fromJson(json['quiz'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'llmQuizResult': llmQuizResult?.toJson(),
      'quiz': quiz?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class LlmQuizResult {
  final ResponseQuiz? responseQuiz;
  final dynamic callDetails; // może być null
  final UsageInfo? usageInfo;
  final String timeSpan;

  LlmQuizResult({
    this.responseQuiz,
    this.callDetails,
    this.usageInfo,
    required this.timeSpan,
  });

  factory LlmQuizResult.fromJson(Map<String, dynamic> json) {
    return LlmQuizResult(
      responseQuiz: json['responseQuiz'] != null
          ? ResponseQuiz.fromJson(json['responseQuiz'])
          : null,
      callDetails: json['callDetails'],
      usageInfo: json['usageInfo'] != null
          ? UsageInfo.fromJson(json['usageInfo'])
          : null,
      timeSpan: json['timeSpan'] ?? '00:00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responseQuiz': responseQuiz?.toJson(),
      'callDetails': callDetails,
      'usageInfo': usageInfo?.toJson(),
      'timeSpan': timeSpan,
    };
  }
}

class UsageInfo {
  final String? modelName;
  final double input1MTokenPriceUsd;
  final double output1MTokenPriceUsd;
  final double inputTokenPriceUsd;
  final double outputTokenPriceUsd;
  final int inputTokenCount;
  final int outputTokenCount;
  final double inputPriceUsd;
  final double outputPriceUsd;
  final double totalPriceUsd;
  final double estimatedTotalPricePlnGr;

  UsageInfo({
    this.modelName,
    required this.input1MTokenPriceUsd,
    required this.output1MTokenPriceUsd,
    required this.inputTokenPriceUsd,
    required this.outputTokenPriceUsd,
    required this.inputTokenCount,
    required this.outputTokenCount,
    required this.inputPriceUsd,
    required this.outputPriceUsd,
    required this.totalPriceUsd,
    required this.estimatedTotalPricePlnGr,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      modelName: json['modelName'],
      input1MTokenPriceUsd: (json['input1MTokenPriceUsd'] ?? 0.0).toDouble(),
      output1MTokenPriceUsd: (json['output1MTokenPriceUsd'] ?? 0.0).toDouble(),
      inputTokenPriceUsd: (json['inputTokenPriceUsd'] ?? 0.0).toDouble(),
      outputTokenPriceUsd: (json['outputTokenPriceUsd'] ?? 0.0).toDouble(),
      inputTokenCount: json['inputTokenCount'] ?? 0,
      outputTokenCount: json['outputTokenCount'] ?? 0,
      inputPriceUsd: (json['inputPriceUsd'] ?? 0.0).toDouble(),
      outputPriceUsd: (json['outputPriceUsd'] ?? 0.0).toDouble(),
      totalPriceUsd: (json['totalPriceUsd'] ?? 0.0).toDouble(),
      estimatedTotalPricePlnGr: (json['estimatedTotalPricePlnGr'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'input1MTokenPriceUsd': input1MTokenPriceUsd,
      'output1MTokenPriceUsd': output1MTokenPriceUsd,
      'inputTokenPriceUsd': inputTokenPriceUsd,
      'outputTokenPriceUsd': outputTokenPriceUsd,
      'inputTokenCount': inputTokenCount,
      'outputTokenCount': outputTokenCount,
      'inputPriceUsd': inputPriceUsd,
      'outputPriceUsd': outputPriceUsd,
      'totalPriceUsd': totalPriceUsd,
      'estimatedTotalPricePlnGr': estimatedTotalPricePlnGr,
    };
  }

  // Pomocnicze gettery dla wyświetlania
  String get formattedTotalTokens => '${inputTokenCount + outputTokenCount}';
  String get formattedInputTokens => inputTokenCount.toString();
  String get formattedOutputTokens => outputTokenCount.toString();
  String get formattedTotalPrice => '\$${totalPriceUsd.toStringAsFixed(4)}';
  String get formattedPricePln => '${(estimatedTotalPricePlnGr / 100).toStringAsFixed(2)} zł';
}

class ResponseQuiz {
  final String? n; // name
  final List<ResponseQuizQuestion>? q; // questions

  ResponseQuiz({this.n, this.q});

  factory ResponseQuiz.fromJson(Map<String, dynamic> json) {
    return ResponseQuiz(
      n: json['n'],
      q: json['q'] != null
          ? (json['q'] as List)
              .map((q) => ResponseQuizQuestion.fromJson(q))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n': n,
      'q': q?.map((q) => q.toJson()).toList(),
    };
  }
}

class ResponseQuizQuestion {
  final String? t; // text
  final String? c; // correct answer
  final String? w1; // wrong answer 1
  final String? w2; // wrong answer 2
  final String? w3; // wrong answer 3
  final String? w4; // wrong answer 4
  final String? w5; // wrong answer 5

  ResponseQuizQuestion({
    this.t,
    this.c,
    this.w1,
    this.w2,
    this.w3,
    this.w4,
    this.w5,
  });

  factory ResponseQuizQuestion.fromJson(Map<String, dynamic> json) {
    return ResponseQuizQuestion(
      t: json['t'],
      c: json['c'],
      w1: json['w1'],
      w2: json['w2'],
      w3: json['w3'],
      w4: json['w4'],
      w5: json['w5'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      't': t,
      'c': c,
      'w1': w1,
      'w2': w2,
      'w3': w3,
      'w4': w4,
      'w5': w5,
    };
  }

  List<String> getAllAnswers() {
    List<String> answers = [];
    if (c != null) answers.add(c!);
    if (w1 != null) answers.add(w1!);
    if (w2 != null) answers.add(w2!);
    if (w3 != null) answers.add(w3!);
    if (w4 != null) answers.add(w4!);
    if (w5 != null) answers.add(w5!);
    return answers;
  }
}