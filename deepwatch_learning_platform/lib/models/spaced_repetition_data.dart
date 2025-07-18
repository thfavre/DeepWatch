import 'package:equatable/equatable.dart';

class SpacedRepetitionData extends Equatable {
  final double easeFactor;
  final int repetitions;
  final int interval;
  final DateTime? nextReviewDate;
  final int totalReviews;
  final int correctReviews;
  final DateTime? lastReviewDate;

  const SpacedRepetitionData({
    required this.easeFactor,
    required this.repetitions,
    required this.interval,
    this.nextReviewDate,
    required this.totalReviews,
    required this.correctReviews,
    this.lastReviewDate,
  });

  // Factory constructor for new flashcards
  factory SpacedRepetitionData.initial() {
    return SpacedRepetitionData(
      easeFactor: 2.5, // Default ease factor for SM2 algorithm
      repetitions: 0,
      interval: 1,
      nextReviewDate: DateTime.now(),
      totalReviews: 0,
      correctReviews: 0,
      lastReviewDate: null,
    );
  }

  // Calculate success rate
  double get successRate {
    if (totalReviews == 0) return 0.0;
    return correctReviews / totalReviews;
  }

  // Check if review is due
  bool get isDue {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'easeFactor': easeFactor,
      'repetitions': repetitions,
      'interval': interval,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'totalReviews': totalReviews,
      'correctReviews': correctReviews,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
    };
  }

  // JSON deserialization
  factory SpacedRepetitionData.fromJson(Map<String, dynamic> json) {
    return SpacedRepetitionData(
      easeFactor: (json['easeFactor'] as num).toDouble(),
      repetitions: json['repetitions'] as int,
      interval: json['interval'] as int,
      nextReviewDate: json['nextReviewDate'] != null 
          ? DateTime.parse(json['nextReviewDate'] as String)
          : null,
      totalReviews: json['totalReviews'] as int,
      correctReviews: json['correctReviews'] as int,
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'] as String)
          : null,
    );
  }

  // Copy with method for immutability
  SpacedRepetitionData copyWith({
    double? easeFactor,
    int? repetitions,
    int? interval,
    DateTime? nextReviewDate,
    int? totalReviews,
    int? correctReviews,
    DateTime? lastReviewDate,
  }) {
    return SpacedRepetitionData(
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
    );
  }

  @override
  List<Object?> get props => [
        easeFactor,
        repetitions,
        interval,
        nextReviewDate,
        totalReviews,
        correctReviews,
        lastReviewDate,
      ];
}