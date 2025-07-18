import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deepwatch_learning_platform/models/learning_group.dart';
import 'package:deepwatch_learning_platform/models/video_item.dart';
import 'package:deepwatch_learning_platform/repositories/learning_group_repository_impl.dart';
import 'package:deepwatch_learning_platform/services/database_helper.dart';

void main() {
  group('LearningGroupRepositoryImpl', () {
    late LearningGroupRepositoryImpl repository;
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Use in-memory database for testing
      databaseHelper = DatabaseHelper();
      repository = LearningGroupRepositoryImpl(databaseHelper: databaseHelper);
      
      // Clean up any existing data
      await databaseHelper.deleteDatabase();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    group('getAllGroups', () {
      test('should return empty list when no groups exist', () async {
        // Act
        final result = await repository.getAllGroups();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all groups with correct progress', () async {
        // Arrange - Create a group first
        const name = 'Test Group';
        final youtubeUrls = [
          'https://www.youtube.com/watch?v=abc123',
          'https://youtu.be/def456',
        ];

        final createdGroup = await repository.createGroup(name, youtubeUrls);
        
        // Mark one video as completed
        await repository.updateVideoCompletion(
          createdGroup.id, 
          createdGroup.videos.first.id, 
          true
        );

        // Act
        final result = await repository.getAllGroups();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, name);
        expect(result.first.progressPercentage, 50.0); // 1 out of 2 videos completed
      });
    });

    group('getGroupById', () {
      test('should return null when group not found', () async {
        // Act
        final result = await repository.getGroupById('nonexistent');

        // Assert
        expect(result, isNull);
      });

      test('should throw ArgumentError for empty ID', () async {
        // Act & Assert
        expect(
          () => repository.getGroupById(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should return group when found', () async {
        // Arrange - Create a group first
        const name = 'Test Group';
        final youtubeUrls = ['https://www.youtube.com/watch?v=abc123'];
        final createdGroup = await repository.createGroup(name, youtubeUrls);

        // Act
        final result = await repository.getGroupById(createdGroup.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, createdGroup.id);
        expect(result.name, name);
      });
    });

    group('createGroup', () {
      test('should create group with valid data', () async {
        // Arrange
        const name = 'Test Group';
        final youtubeUrls = [
          'https://www.youtube.com/watch?v=abc123',
          'https://youtu.be/def456',
        ];

        // Act
        final result = await repository.createGroup(name, youtubeUrls);

        // Assert
        expect(result.name, name);
        expect(result.videos, hasLength(2));
        expect(result.videos[0].youtubeId, 'abc123');
        expect(result.videos[1].youtubeId, 'def456');
        expect(result.progressPercentage, 0.0);
        expect(result.id, isNotEmpty);
      });

      test('should throw ValidationException for invalid name', () async {
        // Act & Assert
        expect(
          () => repository.createGroup('', ['https://youtu.be/abc123']),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for empty YouTube URLs', () async {
        // Act & Assert
        expect(
          () => repository.createGroup('Test Group', []),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for invalid YouTube URL', () async {
        // Act & Assert
        expect(
          () => repository.createGroup('Test Group', ['https://invalid-url.com']),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateGroup', () {
      test('should update group with recalculated progress', () async {
        // Arrange - Create a group first
        const name = 'Test Group';
        final youtubeUrls = ['https://www.youtube.com/watch?v=abc123'];
        final createdGroup = await repository.createGroup(name, youtubeUrls);
        
        // Update the group name
        final updatedGroup = createdGroup.copyWith(name: 'Updated Group');

        // Act
        await repository.updateGroup(updatedGroup);

        // Verify the update
        final result = await repository.getGroupById(createdGroup.id);
        expect(result!.name, 'Updated Group');
      });

      test('should throw ValidationException for invalid name', () async {
        // Arrange
        final group = LearningGroup(
          id: 'group1',
          name: '', // Invalid name
          videos: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          progressPercentage: 0.0,
          metadata: {},
        );

        // Act & Assert
        expect(
          () => repository.updateGroup(group),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('deleteGroup', () {
      test('should delete existing group', () async {
        // Arrange - Create a group first
        const name = 'Test Group';
        final youtubeUrls = ['https://www.youtube.com/watch?v=abc123'];
        final createdGroup = await repository.createGroup(name, youtubeUrls);

        // Act
        await repository.deleteGroup(createdGroup.id);

        // Assert - Group should no longer exist
        final result = await repository.getGroupById(createdGroup.id);
        expect(result, isNull);
      });

      test('should throw NotFoundException for non-existent group', () async {
        // Act & Assert
        expect(
          () => repository.deleteGroup('nonexistent'),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('should throw ArgumentError for empty ID', () async {
        // Act & Assert
        expect(
          () => repository.deleteGroup(''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('calculateGroupProgress', () {
      test('should return 0 for empty video list', () {
        // Act
        final progress = repository.calculateGroupProgress([]);

        // Assert
        expect(progress, 0.0);
      });

      test('should calculate correct progress percentage', () {
        // Arrange
        final videos = [
          VideoItem(
            id: 'video1',
            youtubeId: 'abc123',
            title: 'Video 1',
            thumbnailUrl: 'https://example.com/thumb1.jpg',
            duration: const Duration(minutes: 10),
            isCompleted: true,
            notes: '',
            tags: [],
            lastWatched: DateTime.now(),
            orderIndex: 0,
          ),
          VideoItem(
            id: 'video2',
            youtubeId: 'def456',
            title: 'Video 2',
            thumbnailUrl: 'https://example.com/thumb2.jpg',
            duration: const Duration(minutes: 15),
            isCompleted: false,
            notes: '',
            tags: [],
            lastWatched: DateTime.now(),
            orderIndex: 1,
          ),
          VideoItem(
            id: 'video3',
            youtubeId: 'ghi789',
            title: 'Video 3',
            thumbnailUrl: 'https://example.com/thumb3.jpg',
            duration: const Duration(minutes: 20),
            isCompleted: true,
            notes: '',
            tags: [],
            lastWatched: DateTime.now(),
            orderIndex: 2,
          ),
        ];

        // Act
        final progress = repository.calculateGroupProgress(videos);

        // Assert
        expect(progress, 66.67); // 2 out of 3 videos completed
      });

      test('should return 100 when all videos are completed', () {
        // Arrange
        final videos = [
          VideoItem(
            id: 'video1',
            youtubeId: 'abc123',
            title: 'Video 1',
            thumbnailUrl: 'https://example.com/thumb1.jpg',
            duration: const Duration(minutes: 10),
            isCompleted: true,
            notes: '',
            tags: [],
            lastWatched: DateTime.now(),
            orderIndex: 0,
          ),
          VideoItem(
            id: 'video2',
            youtubeId: 'def456',
            title: 'Video 2',
            thumbnailUrl: 'https://example.com/thumb2.jpg',
            duration: const Duration(minutes: 15),
            isCompleted: true,
            notes: '',
            tags: [],
            lastWatched: DateTime.now(),
            orderIndex: 1,
          ),
        ];

        // Act
        final progress = repository.calculateGroupProgress(videos);

        // Assert
        expect(progress, 100.0);
      });
    });

    group('updateVideoCompletion', () {
      test('should update video completion and group progress', () async {
        // Arrange - Create a group first
        const name = 'Test Group';
        final youtubeUrls = ['https://www.youtube.com/watch?v=abc123'];
        final createdGroup = await repository.createGroup(name, youtubeUrls);
        final videoId = createdGroup.videos.first.id;

        // Act
        await repository.updateVideoCompletion(createdGroup.id, videoId, true);

        // Assert
        final updatedGroup = await repository.getGroupById(createdGroup.id);
        expect(updatedGroup!.progressPercentage, 100.0);
        expect(updatedGroup.videos.first.isCompleted, true);
      });

      test('should throw NotFoundException for non-existent video', () async {
        // Act & Assert
        expect(
          () => repository.updateVideoCompletion('group1', 'nonexistent', true),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('should throw ArgumentError for empty IDs', () async {
        // Act & Assert
        expect(
          () => repository.updateVideoCompletion('', 'video1', true),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => repository.updateVideoCompletion('group1', '', true),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('reorderVideos', () {
      test('should reorder videos correctly', () async {
        // Arrange - Create a group with multiple videos
        const name = 'Test Group';
        final youtubeUrls = [
          'https://www.youtube.com/watch?v=abc123',
          'https://youtu.be/def456',
        ];
        final createdGroup = await repository.createGroup(name, youtubeUrls);
        final video1Id = createdGroup.videos[0].id;
        final video2Id = createdGroup.videos[1].id;

        // Act - Reverse the order
        await repository.reorderVideos(createdGroup.id, [video2Id, video1Id]);

        // Assert
        final updatedGroup = await repository.getGroupById(createdGroup.id);
        expect(updatedGroup!.videos[0].id, video2Id);
        expect(updatedGroup.videos[0].orderIndex, 0);
        expect(updatedGroup.videos[1].id, video1Id);
        expect(updatedGroup.videos[1].orderIndex, 1);
      });

      test('should throw ValidationException for mismatched video IDs', () async {
        // Arrange - Create a group first
        const name = 'Test Group';
        final youtubeUrls = ['https://www.youtube.com/watch?v=abc123'];
        final createdGroup = await repository.createGroup(name, youtubeUrls);

        // Act & Assert - Provide different video IDs
        expect(
          () => repository.reorderVideos(createdGroup.id, ['video2', 'video3']),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ArgumentError for empty group ID', () async {
        // Act & Assert
        expect(
          () => repository.reorderVideos('', ['video1']),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for empty video IDs list', () async {
        // Act & Assert
        expect(
          () => repository.reorderVideos('group1', []),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}