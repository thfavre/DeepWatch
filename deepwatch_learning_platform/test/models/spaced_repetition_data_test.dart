import 'package:flutter_test/flutter_test.dart';
import 'package:deepwatch_learning_platform/models/spaced_repetition_data.dart';

void main() {
  group('SpacedRepetitionData', () {
    late SpacedRepetitionData testData;

    setUp(() {
      testData = const SpacedRepetitionData(
        easeFactor: 2.5,
        repetitions: 3,
        interval: 7,
        nextReviewDate: null,
        totalReviews: 10,
        correctReviews: 8,
        lastReviewDate: null,
      );
    });

    group('Initial Factory Constructor', () {
      test('should create initial data with correct defaults', () {
        final initialData = SpacedRepetitionData.initial();

        expect(initialData.easeFactor, equals(2.5));
        expect(initialData.repetitions, equals(0));
        expect(initialData.interval, equals(1));
        expect(initialData.totalReviews, equals(0));
        expect(initialData.correctReviews, equals(0));
        expect(initialData.nextReviewDate, isNotNull);
        expect(initialData.lastReviewDate, isNull);
      });
    });

    group('Success Rate Calculation', () {
      test('should calculate success rate correctly', () {
        expect(testData.successRate, equals(0.8)); // 8/10
      });

      test('should return 0 for no reviews', () {
        final noReviewsData = testData.copyWith(totalReviews: 0, correctReviews: 0);
        expect(noReviewsData.successRate, equals(0.0));
      });

      test('should handle perfect success rate', () {
        final perfectData = testData.copyWith(totalReviews: 5, correctReviews: 5);
        expect(perfectData.successRate, equals(1.0));
      });
    });

    group('Due Date Checking', () {
      test('should be due when nextReviewDate is null', () {
        final noDueDateData = testData.copyWith(nextReviewDate: null);
        expect(noDueDateData.isDue, isTrue);
      });

      test('should be due when nextReviewDate is in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final pastDueData = testData.copyWith(nextReviewDate: pastDate);
        expect(pastDueData.isDue, isTrue);
      });

      test('should not be due when nextReviewDate is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final futureDueData = testData.copyWith(nextReviewDate: futureDate);
        expect(futureDueData.isDue, isFalse);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final testDateTime = DateTime(2024, 1, 1);
        final dataWithDates = testData.copyWith(
          nextReviewDate: testDateTime,
          lastReviewDate: testDateTime,
        );
        
        final json = dataWithDates.toJson();

        expect(json['easeFactor'], equals(2.5));
        expect(json['repetitions'], equals(3));
        expect(json['interval'], equals(7));
        expect(json['nextReviewDate'], equals('2024-01-01T00:00:00.000'));
        expect(json['totalReviews'], equals(10));
        expect(json['correctReviews'], equals(8));
        expect(json['lastReviewDate'], equals('2024-01-01T00:00:00.000'));
      });

      test('should serialize null dates correctly', () {
        final json = testData.toJson();

        expect(json['nextReviewDate'], isNull);
        expect(json['lastReviewDate'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'easeFactor': 2.5,
          'repetitions': 3,
          'interval': 7,
          'nextReviewDate': '2024-01-01T00:00:00.000',
          'totalReviews': 10,
          'correctReviews': 8,
          'lastReviewDate': '2024-01-01T00:00:00.000',
        };

        final data = SpacedRepetitionData.fromJson(json);

        expect(data.easeFactor, equals(2.5));
        expect(data.repetitions, equals(3));
        expect(data.interval, equals(7));
        expect(data.nextReviewDate, equals(DateTime(2024, 1, 1)));
        expect(data.totalReviews, equals(10));
        expect(data.correctReviews, equals(8));
        expect(data.lastReviewDate, equals(DateTime(2024, 1, 1)));
      });

      test('should handle null dates in JSON deserialization', () {
        final json = {
          'easeFactor': 2.5,
          'repetitions': 3,
          'interval': 7,
          'nextReviewDate': null,
          'totalReviews': 10,
          'correctReviews': 8,
          'lastReviewDate': null,
        };

        final data = SpacedRepetitionData.fromJson(json);

        expect(data.nextReviewDate, isNull);
        expect(data.lastReviewDate, isNull);
      });

      test('should maintain data integrity through serialization round-trip', () {
        final testDateTime = DateTime(2024, 1, 1);
        final dataWithDates = testData.copyWith(
          nextReviewDate: testDateTime,
          lastReviewDate: testDateTime,
        );
        
        final json = dataWithDates.toJson();
        final deserializedData = SpacedRepetitionData.fromJson(json);

        expect(deserializedData, equals(dataWithDates));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedData = testData.copyWith(
          easeFactor: 3.0,
          repetitions: 5,
        );

        expect(updatedData.easeFactor, equals(3.0));
        expect(updatedData.repetitions, equals(5));
        expect(updatedData.interval, equals(testData.interval));
        expect(updatedData.totalReviews, equals(testData.totalReviews));
      });

      test('should create identical copy when no fields are updated', () {
        final copiedData = testData.copyWith();

        expect(copiedData, equals(testData));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        const data1 = SpacedRepetitionData(
          easeFactor: 2.5,
          repetitions: 3,
          interval: 7,
          nextReviewDate: null,
          totalReviews: 10,
          correctReviews: 8,
          lastReviewDate: null,
        );

        const data2 = SpacedRepetitionData(
          easeFactor: 2.5,
          repetitions: 3,
          interval: 7,
          nextReviewDate: null,
          totalReviews: 10,
          correctReviews: 8,
          lastReviewDate: null,
        );

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final data2 = testData.copyWith(easeFactor: 3.0);

        expect(testData, isNot(equals(data2)));
      });
    });
  });
}