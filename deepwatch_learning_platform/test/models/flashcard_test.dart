import 'package:flutter_test/flutter_test.dart';
import 'package:deepwatch_learning_platform/models/flashcard.dart';
import 'package:deepwatch_learning_platform/models/spaced_repetition_data.dart';

void main() {
  group('Flashcard', () {
    late Flashcard testFlashcard;
    late SpacedRepetitionData testRepetitionData;

    setUp(() {
      testRepetitionData = SpacedRepetitionData.initial();
      testFlashcard = Flashcard(
        id: 'flashcard-1',
        question: 'What is the capital of France?',
        answer: 'Paris',
        sourceVideoId: 'video-1',
        tags: ['geography', 'capitals'],
        repetitionData: testRepetitionData,
        createdAt: DateTime(2024, 1, 1),
        sourceNotes: 'Notes about French geography',
      );
    });

    group('Question Validation', () {
      test('should accept valid questions', () {
        expect(Flashcard.validateQuestion('What is the capital?'), isNull);
        expect(Flashcard.validateQuestion('Valid question with enough characters'), isNull);
      });

      test('should reject empty questions', () {
        expect(Flashcard.validateQuestion(''), isNotNull);
        expect(Flashcard.validateQuestion(null), isNotNull);
        expect(Flashcard.validateQuestion('   '), isNotNull);
      });

      test('should reject questions that are too short', () {
        expect(Flashcard.validateQuestion('What'), isNotNull);
        expect(Flashcard.validateQuestion('A?'), isNotNull);
      });

      test('should reject questions that are too long', () {
        final longQuestion = 'A' * 501;
        expect(Flashcard.validateQuestion(longQuestion), isNotNull);
      });
    });

    group('Answer Validation', () {
      test('should accept valid answers', () {
        expect(Flashcard.validateAnswer('Paris'), isNull);
        expect(Flashcard.validateAnswer('A valid answer'), isNull);
      });

      test('should reject empty answers', () {
        expect(Flashcard.validateAnswer(''), isNotNull);
        expect(Flashcard.validateAnswer(null), isNotNull);
        expect(Flashcard.validateAnswer('   '), isNotNull);
      });

      test('should reject answers that are too short', () {
        expect(Flashcard.validateAnswer('A'), isNotNull);
      });

      test('should reject answers that are too long', () {
        final longAnswer = 'A' * 1001;
        expect(Flashcard.validateAnswer(longAnswer), isNotNull);
      });
    });

    group('Source Video ID Validation', () {
      test('should accept valid source video IDs', () {
        expect(Flashcard.validateSourceVideoId('video-123'), isNull);
        expect(Flashcard.validateSourceVideoId('abc-def-ghi'), isNull);
      });

      test('should reject empty source video IDs', () {
        expect(Flashcard.validateSourceVideoId(''), isNotNull);
        expect(Flashcard.validateSourceVideoId(null), isNotNull);
        expect(Flashcard.validateSourceVideoId('   '), isNotNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testFlashcard.toJson();

        expect(json['id'], equals('flashcard-1'));
        expect(json['question'], equals('What is the capital of France?'));
        expect(json['answer'], equals('Paris'));
        expect(json['sourceVideoId'], equals('video-1'));
        expect(json['tags'], equals(['geography', 'capitals']));
        expect(json['repetitionData'], isA<Map<String, dynamic>>());
        expect(json['createdAt'], equals('2024-01-01T00:00:00.000'));
        expect(json['sourceNotes'], equals('Notes about French geography'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'flashcard-1',
          'question': 'What is the capital of France?',
          'answer': 'Paris',
          'sourceVideoId': 'video-1',
          'tags': ['geography', 'capitals'],
          'repetitionData': testRepetitionData.toJson(),
          'createdAt': '2024-01-01T00:00:00.000',
          'sourceNotes': 'Notes about French geography',
        };

        final flashcard = Flashcard.fromJson(json);

        expect(flashcard.id, equals('flashcard-1'));
        expect(flashcard.question, equals('What is the capital of France?'));
        expect(flashcard.answer, equals('Paris'));
        expect(flashcard.sourceVideoId, equals('video-1'));
        expect(flashcard.tags, equals(['geography', 'capitals']));
        expect(flashcard.repetitionData, equals(testRepetitionData));
        expect(flashcard.createdAt, equals(DateTime(2024, 1, 1)));
        expect(flashcard.sourceNotes, equals('Notes about French geography'));
      });

      test('should maintain data integrity through serialization round-trip', () {
        final json = testFlashcard.toJson();
        final deserializedFlashcard = Flashcard.fromJson(json);

        expect(deserializedFlashcard, equals(testFlashcard));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedFlashcard = testFlashcard.copyWith(
          question: 'What is the capital of Germany?',
          answer: 'Berlin',
        );

        expect(updatedFlashcard.question, equals('What is the capital of Germany?'));
        expect(updatedFlashcard.answer, equals('Berlin'));
        expect(updatedFlashcard.id, equals(testFlashcard.id));
        expect(updatedFlashcard.sourceVideoId, equals(testFlashcard.sourceVideoId));
      });

      test('should create identical copy when no fields are updated', () {
        final copiedFlashcard = testFlashcard.copyWith();

        expect(copiedFlashcard, equals(testFlashcard));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final flashcard1 = Flashcard(
          id: 'flashcard-1',
          question: 'What is the capital of France?',
          answer: 'Paris',
          sourceVideoId: 'video-1',
          tags: ['geography', 'capitals'],
          repetitionData: testRepetitionData,
          createdAt: DateTime(2024, 1, 1),
          sourceNotes: 'Notes about French geography',
        );

        final flashcard2 = Flashcard(
          id: 'flashcard-1',
          question: 'What is the capital of France?',
          answer: 'Paris',
          sourceVideoId: 'video-1',
          tags: ['geography', 'capitals'],
          repetitionData: testRepetitionData,
          createdAt: DateTime(2024, 1, 1),
          sourceNotes: 'Notes about French geography',
        );

        expect(flashcard1, equals(flashcard2));
        expect(flashcard1.hashCode, equals(flashcard2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final flashcard2 = testFlashcard.copyWith(question: 'Different question?');

        expect(testFlashcard, isNot(equals(flashcard2)));
      });
    });
  });
}