import 'package:equatable/equatable.dart';
import 'package:deepwatch_learning_platform/models/spaced_repetition_data.dart';

class Flashcard extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String sourceVideoId;
  final List<String> tags;
  final SpacedRepetitionData repetitionData;
  final DateTime createdAt;
  final String sourceNotes;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.sourceVideoId,
    required this.tags,
    required this.repetitionData,
    required this.createdAt,
    required this.sourceNotes,
  });

  // Validation methods
  static String? validateQuestion(String? question) {
    if (question == null || question.trim().isEmpty) {
      return 'Question is required';
    }
    if (question.trim().length < 5) {
      return 'Question must be at least 5 characters';
    }
    if (question.trim().length > 500) {
      return 'Question must be less than 500 characters';
    }
    return null;
  }

  static String? validateAnswer(String? answer) {
    if (answer == null || answer.trim().isEmpty) {
      return 'Answer is required';
    }
    if (answer.trim().length < 2) {
      return 'Answer must be at least 2 characters';
    }
    if (answer.trim().length > 1000) {
      return 'Answer must be less than 1000 characters';
    }
    return null;
  }

  static String? validateSourceVideoId(String? sourceVideoId) {
    if (sourceVideoId == null || sourceVideoId.trim().isEmpty) {
      return 'Source video ID is required';
    }
    return null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'sourceVideoId': sourceVideoId,
      'tags': tags,
      'repetitionData': repetitionData.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'sourceNotes': sourceNotes,
    };
  }

  // JSON deserialization
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      sourceVideoId: json['sourceVideoId'] as String,
      tags: List<String>.from(json['tags'] as List),
      repetitionData: SpacedRepetitionData.fromJson(json['repetitionData'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      sourceNotes: json['sourceNotes'] as String,
    );
  }

  // Copy with method for immutability
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? sourceVideoId,
    List<String>? tags,
    SpacedRepetitionData? repetitionData,
    DateTime? createdAt,
    String? sourceNotes,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      sourceVideoId: sourceVideoId ?? this.sourceVideoId,
      tags: tags ?? this.tags,
      repetitionData: repetitionData ?? this.repetitionData,
      createdAt: createdAt ?? this.createdAt,
      sourceNotes: sourceNotes ?? this.sourceNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        sourceVideoId,
        tags,
        repetitionData,
        createdAt,
        sourceNotes,
      ];
}