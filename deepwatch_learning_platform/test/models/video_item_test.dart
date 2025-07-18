import 'package:flutter_test/flutter_test.dart';
import 'package:deepwatch_learning_platform/models/video_item.dart';

void main() {
  group('VideoItem', () {
    late VideoItem testVideoItem;

    setUp(() {
      testVideoItem = VideoItem(
        id: 'test-id',
        youtubeId: 'dQw4w9WgXcQ',
        title: 'Test Video',
        thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        duration: const Duration(minutes: 3, seconds: 32),
        isCompleted: false,
        notes: 'Test notes',
        tags: ['test', 'video'],
        lastWatched: DateTime(2024, 1, 1),
        orderIndex: 0,
      );
    });

    group('YouTube URL Validation', () {
      test('should validate standard YouTube URLs', () {
        expect(VideoItem.validateYouTubeUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), isNull);
        expect(VideoItem.validateYouTubeUrl('https://youtube.com/watch?v=dQw4w9WgXcQ'), isNull);
        expect(VideoItem.validateYouTubeUrl('http://www.youtube.com/watch?v=dQw4w9WgXcQ'), isNull);
      });

      test('should validate short YouTube URLs', () {
        expect(VideoItem.validateYouTubeUrl('https://youtu.be/dQw4w9WgXcQ'), isNull);
        expect(VideoItem.validateYouTubeUrl('http://youtu.be/dQw4w9WgXcQ'), isNull);
      });

      test('should validate embed YouTube URLs', () {
        expect(VideoItem.validateYouTubeUrl('https://www.youtube.com/embed/dQw4w9WgXcQ'), isNull);
        expect(VideoItem.validateYouTubeUrl('https://youtube.com/embed/dQw4w9WgXcQ'), isNull);
      });

      test('should reject invalid URLs', () {
        expect(VideoItem.validateYouTubeUrl(''), isNotNull);
        expect(VideoItem.validateYouTubeUrl(null), isNotNull);
        expect(VideoItem.validateYouTubeUrl('https://vimeo.com/123456'), isNotNull);
        expect(VideoItem.validateYouTubeUrl('https://youtube.com/watch?v=invalid'), isNotNull);
        expect(VideoItem.validateYouTubeUrl('not-a-url'), isNotNull);
      });
    });

    group('YouTube ID Extraction', () {
      test('should extract ID from standard URLs', () {
        expect(VideoItem.extractYouTubeId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
        expect(VideoItem.extractYouTubeId('https://youtube.com/watch?v=dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      });

      test('should extract ID from short URLs', () {
        expect(VideoItem.extractYouTubeId('https://youtu.be/dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      });

      test('should extract ID from embed URLs', () {
        expect(VideoItem.extractYouTubeId('https://www.youtube.com/embed/dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      });

      test('should return null for invalid URLs', () {
        expect(VideoItem.extractYouTubeId('invalid-url'), isNull);
        expect(VideoItem.extractYouTubeId('https://vimeo.com/123456'), isNull);
      });
    });

    group('Title Validation', () {
      test('should accept valid titles', () {
        expect(VideoItem.validateTitle('Valid Title'), isNull);
        expect(VideoItem.validateTitle('A'), isNull);
      });

      test('should reject empty titles', () {
        expect(VideoItem.validateTitle(''), isNotNull);
        expect(VideoItem.validateTitle(null), isNotNull);
        expect(VideoItem.validateTitle('   '), isNotNull);
      });

      test('should reject titles that are too long', () {
        final longTitle = 'A' * 201;
        expect(VideoItem.validateTitle(longTitle), isNotNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testVideoItem.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['youtubeId'], equals('dQw4w9WgXcQ'));
        expect(json['title'], equals('Test Video'));
        expect(json['thumbnailUrl'], equals('https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg'));
        expect(json['duration'], equals(212)); // 3:32 in seconds
        expect(json['isCompleted'], equals(false));
        expect(json['notes'], equals('Test notes'));
        expect(json['tags'], equals(['test', 'video']));
        expect(json['lastWatched'], equals('2024-01-01T00:00:00.000'));
        expect(json['orderIndex'], equals(0));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test-id',
          'youtubeId': 'dQw4w9WgXcQ',
          'title': 'Test Video',
          'thumbnailUrl': 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          'duration': 212,
          'isCompleted': false,
          'notes': 'Test notes',
          'tags': ['test', 'video'],
          'lastWatched': '2024-01-01T00:00:00.000',
          'orderIndex': 0,
        };

        final videoItem = VideoItem.fromJson(json);

        expect(videoItem.id, equals('test-id'));
        expect(videoItem.youtubeId, equals('dQw4w9WgXcQ'));
        expect(videoItem.title, equals('Test Video'));
        expect(videoItem.thumbnailUrl, equals('https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg'));
        expect(videoItem.duration, equals(const Duration(minutes: 3, seconds: 32)));
        expect(videoItem.isCompleted, equals(false));
        expect(videoItem.notes, equals('Test notes'));
        expect(videoItem.tags, equals(['test', 'video']));
        expect(videoItem.lastWatched, equals(DateTime(2024, 1, 1)));
        expect(videoItem.orderIndex, equals(0));
      });

      test('should maintain data integrity through serialization round-trip', () {
        final json = testVideoItem.toJson();
        final deserializedVideoItem = VideoItem.fromJson(json);

        expect(deserializedVideoItem, equals(testVideoItem));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedVideoItem = testVideoItem.copyWith(
          title: 'Updated Title',
          isCompleted: true,
        );

        expect(updatedVideoItem.title, equals('Updated Title'));
        expect(updatedVideoItem.isCompleted, equals(true));
        expect(updatedVideoItem.id, equals(testVideoItem.id));
        expect(updatedVideoItem.youtubeId, equals(testVideoItem.youtubeId));
      });

      test('should create identical copy when no fields are updated', () {
        final copiedVideoItem = testVideoItem.copyWith();

        expect(copiedVideoItem, equals(testVideoItem));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final videoItem1 = VideoItem(
          id: 'test-id',
          youtubeId: 'dQw4w9WgXcQ',
          title: 'Test Video',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          duration: const Duration(minutes: 3, seconds: 32),
          isCompleted: false,
          notes: 'Test notes',
          tags: ['test', 'video'],
          lastWatched: DateTime(2024, 1, 1),
          orderIndex: 0,
        );

        final videoItem2 = VideoItem(
          id: 'test-id',
          youtubeId: 'dQw4w9WgXcQ',
          title: 'Test Video',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
          duration: const Duration(minutes: 3, seconds: 32),
          isCompleted: false,
          notes: 'Test notes',
          tags: ['test', 'video'],
          lastWatched: DateTime(2024, 1, 1),
          orderIndex: 0,
        );

        expect(videoItem1, equals(videoItem2));
        expect(videoItem1.hashCode, equals(videoItem2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final videoItem2 = testVideoItem.copyWith(title: 'Different Title');

        expect(testVideoItem, isNot(equals(videoItem2)));
      });
    });
  });
}