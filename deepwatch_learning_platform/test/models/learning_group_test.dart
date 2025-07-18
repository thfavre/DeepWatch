import 'package:flutter_test/flutter_test.dart';
import 'package:deepwatch_learning_platform/models/learning_group.dart';
import 'package:deepwatch_learning_platform/models/video_item.dart';

void main() {
  group('LearningGroup', () {
    late LearningGroup testLearningGroup;
    late List<VideoItem> testVideos;

    setUp(() {
      testVideos = [
        VideoItem(
          id: 'video-1',
          youtubeId: 'dQw4w9WgXcQ',
          title: 'Test Video 1',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          duration: const Duration(minutes: 3, seconds: 32),
          isCompleted: false,
          notes: 'Test notes 1',
          tags: ['test'],
          lastWatched: DateTime(2024, 1, 1),
          orderIndex: 0,
        ),
        VideoItem(
          id: 'video-2',
          youtubeId: 'abc123def45',
          title: 'Test Video 2',
          thumbnailUrl: 'https://img.youtube.com/vi/abc123def45/maxresdefault.jpg',
          duration: const Duration(minutes: 5, seconds: 15),
          isCompleted: true,
          notes: 'Test notes 2',
          tags: ['test', 'completed'],
          lastWatched: DateTime(2024, 1, 2),
          orderIndex: 1,
        ),
      ];

      testLearningGroup = LearningGroup(
        id: 'group-1',
        name: 'Test Learning Group',
        videos: testVideos,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        progressPercentage: 50.0,
        metadata: {'category': 'test', 'difficulty': 'beginner'},
      );
    });

    group('Name Validation', () {
      test('should accept valid names', () {
        expect(LearningGroup.validateName('Valid Name'), isNull);
        expect(LearningGroup.validateName('AB'), isNull);
        expect(LearningGroup.validateName('A' * 100), isNull);
      });

      test('should reject empty names', () {
        expect(LearningGroup.validateName(''), isNotNull);
        expect(LearningGroup.validateName(null), isNotNull);
        expect(LearningGroup.validateName('   '), isNotNull);
      });

      test('should reject names that are too short', () {
        expect(LearningGroup.validateName('A'), isNotNull);
      });

      test('should reject names that are too long', () {
        final longName = 'A' * 101;
        expect(LearningGroup.validateName(longName), isNotNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testLearningGroup.toJson();

        expect(json['id'], equals('group-1'));
        expect(json['name'], equals('Test Learning Group'));
        expect(json['videos'], isA<List>());
        expect(json['videos'].length, equals(2));
        expect(json['createdAt'], equals('2024-01-01T00:00:00.000'));
        expect(json['updatedAt'], equals('2024-01-02T00:00:00.000'));
        expect(json['progressPercentage'], equals(50.0));
        expect(json['metadata'], equals({'category': 'test', 'difficulty': 'beginner'}));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'group-1',
          'name': 'Test Learning Group',
          'videos': testVideos.map((v) => v.toJson()).toList(),
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-02T00:00:00.000',
          'progressPercentage': 50.0,
          'metadata': {'category': 'test', 'difficulty': 'beginner'},
        };

        final learningGroup = LearningGroup.fromJson(json);

        expect(learningGroup.id, equals('group-1'));
        expect(learningGroup.name, equals('Test Learning Group'));
        expect(learningGroup.videos.length, equals(2));
        expect(learningGroup.videos[0].id, equals('video-1'));
        expect(learningGroup.videos[1].id, equals('video-2'));
        expect(learningGroup.createdAt, equals(DateTime(2024, 1, 1)));
        expect(learningGroup.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(learningGroup.progressPercentage, equals(50.0));
        expect(learningGroup.metadata, equals({'category': 'test', 'difficulty': 'beginner'}));
      });

      test('should maintain data integrity through serialization round-trip', () {
        final json = testLearningGroup.toJson();
        final deserializedGroup = LearningGroup.fromJson(json);

        expect(deserializedGroup, equals(testLearningGroup));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedGroup = testLearningGroup.copyWith(
          name: 'Updated Group Name',
          progressPercentage: 75.0,
        );

        expect(updatedGroup.name, equals('Updated Group Name'));
        expect(updatedGroup.progressPercentage, equals(75.0));
        expect(updatedGroup.id, equals(testLearningGroup.id));
        expect(updatedGroup.videos, equals(testLearningGroup.videos));
      });

      test('should create identical copy when no fields are updated', () {
        final copiedGroup = testLearningGroup.copyWith();

        expect(copiedGroup, equals(testLearningGroup));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final group1 = LearningGroup(
          id: 'group-1',
          name: 'Test Learning Group',
          videos: testVideos,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          progressPercentage: 50.0,
          metadata: {'category': 'test', 'difficulty': 'beginner'},
        );

        final group2 = LearningGroup(
          id: 'group-1',
          name: 'Test Learning Group',
          videos: testVideos,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          progressPercentage: 50.0,
          metadata: {'category': 'test', 'difficulty': 'beginner'},
        );

        expect(group1, equals(group2));
        expect(group1.hashCode, equals(group2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final group2 = testLearningGroup.copyWith(name: 'Different Name');

        expect(testLearningGroup, isNot(equals(group2)));
      });
    });
  });
}