import 'dart:math';
import 'package:deepwatch_learning_platform/models/learning_group.dart';
import 'package:deepwatch_learning_platform/models/video_item.dart';
import 'package:deepwatch_learning_platform/services/database_helper.dart';
import 'package:deepwatch_learning_platform/repositories/learning_group_repository.dart';

/// Concrete implementation of LearningGroupRepository using SQLite database
class LearningGroupRepositoryImpl implements LearningGroupRepository {
  final DatabaseHelper _databaseHelper;

  LearningGroupRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  Future<List<LearningGroup>> getAllGroups() async {
    try {
      final groups = await _databaseHelper.getAllLearningGroups();
      
      // Recalculate progress for each group to ensure accuracy
      final updatedGroups = <LearningGroup>[];
      for (final group in groups) {
        final progress = calculateGroupProgress(group.videos);
        if (progress != group.progressPercentage) {
          final updatedGroup = group.copyWith(
            progressPercentage: progress,
            updatedAt: DateTime.now(),
          );
          await _databaseHelper.updateLearningGroup(updatedGroup);
          updatedGroups.add(updatedGroup);
        } else {
          updatedGroups.add(group);
        }
      }
      
      return updatedGroups;
    } catch (e) {
      throw RepositoryException('Failed to get all groups: $e');
    }
  }

  @override
  Future<LearningGroup?> getGroupById(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Group ID cannot be empty');
      }
      
      final group = await _databaseHelper.getLearningGroupById(id);
      if (group == null) return null;
      
      // Ensure progress is up to date
      final progress = calculateGroupProgress(group.videos);
      if (progress != group.progressPercentage) {
        final updatedGroup = group.copyWith(
          progressPercentage: progress,
          updatedAt: DateTime.now(),
        );
        await _databaseHelper.updateLearningGroup(updatedGroup);
        return updatedGroup;
      }
      
      return group;
    } catch (e) {
      throw RepositoryException('Failed to get group by ID: $e');
    }
  }

  @override
  Future<LearningGroup> createGroup(String name, List<String> youtubeUrls) async {
    try {
      // Validate input
      final nameValidation = LearningGroup.validateName(name);
      if (nameValidation != null) {
        throw ValidationException(nameValidation);
      }

      if (youtubeUrls.isEmpty) {
        throw ValidationException('At least one YouTube URL is required');
      }

      // Validate all YouTube URLs
      final validatedUrls = <String>[];
      for (final url in youtubeUrls) {
        final urlValidation = VideoItem.validateYouTubeUrl(url);
        if (urlValidation != null) {
          throw ValidationException('Invalid YouTube URL: $url - $urlValidation');
        }
        validatedUrls.add(url.trim());
      }

      // Generate unique ID
      final groupId = _generateId();
      final now = DateTime.now();

      // Create video items from YouTube URLs
      final videos = <VideoItem>[];
      for (int i = 0; i < validatedUrls.length; i++) {
        final url = validatedUrls[i];
        final youtubeId = VideoItem.extractYouTubeId(url);
        
        if (youtubeId == null) {
          throw ValidationException('Could not extract YouTube ID from URL: $url');
        }

        final videoId = _generateId();
        final video = VideoItem(
          id: videoId,
          youtubeId: youtubeId,
          title: 'Video ${i + 1}', // Placeholder title, will be updated by YouTube service
          thumbnailUrl: 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg',
          duration: const Duration(seconds: 0), // Will be updated by YouTube service
          isCompleted: false,
          notes: '',
          tags: [],
          lastWatched: now,
          orderIndex: i,
        );
        videos.add(video);
      }

      // Calculate initial progress (should be 0 since no videos are completed)
      final progress = calculateGroupProgress(videos);

      // Create learning group
      final group = LearningGroup(
        id: groupId,
        name: name.trim(),
        videos: videos,
        createdAt: now,
        updatedAt: now,
        progressPercentage: progress,
        metadata: {},
      );

      // Save to database
      await _databaseHelper.insertLearningGroup(group);

      return group;
    } catch (e) {
      if (e is ValidationException || e is ArgumentError) {
        rethrow;
      }
      throw RepositoryException('Failed to create group: $e');
    }
  }

  @override
  Future<void> updateGroup(LearningGroup group) async {
    try {
      // Validate group data
      final nameValidation = LearningGroup.validateName(group.name);
      if (nameValidation != null) {
        throw ValidationException(nameValidation);
      }

      // Recalculate progress
      final progress = calculateGroupProgress(group.videos);
      final updatedGroup = group.copyWith(
        progressPercentage: progress,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateLearningGroup(updatedGroup);
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw RepositoryException('Failed to update group: $e');
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Group ID cannot be empty');
      }

      // Check if group exists
      final existingGroup = await _databaseHelper.getLearningGroupById(id);
      if (existingGroup == null) {
        throw NotFoundException('Group with ID $id not found');
      }

      await _databaseHelper.deleteLearningGroup(id);
    } catch (e) {
      if (e is NotFoundException || e is ArgumentError) {
        rethrow;
      }
      throw RepositoryException('Failed to delete group: $e');
    }
  }

  @override
  double calculateGroupProgress(List<VideoItem> videos) {
    if (videos.isEmpty) return 0.0;
    
    final completedCount = videos.where((video) => video.isCompleted).length;
    final progress = (completedCount / videos.length) * 100;
    
    // Round to 2 decimal places
    return double.parse(progress.toStringAsFixed(2));
  }

  @override
  Future<void> updateVideoCompletion(String groupId, String videoId, bool isCompleted) async {
    try {
      if (groupId.trim().isEmpty || videoId.trim().isEmpty) {
        throw ArgumentError('Group ID and Video ID cannot be empty');
      }

      // Get the current video
      final video = await _databaseHelper.getVideoItemById(videoId);
      if (video == null) {
        throw NotFoundException('Video with ID $videoId not found');
      }

      // Update video completion status
      final updatedVideo = video.copyWith(
        isCompleted: isCompleted,
        lastWatched: DateTime.now(),
      );
      await _databaseHelper.updateVideoItem(updatedVideo);

      // Get the group and recalculate progress
      final group = await _databaseHelper.getLearningGroupById(groupId);
      if (group != null) {
        final updatedVideos = group.videos.map((v) {
          return v.id == videoId ? updatedVideo : v;
        }).toList();
        
        final progress = calculateGroupProgress(updatedVideos);
        final updatedGroup = group.copyWith(
          videos: updatedVideos,
          progressPercentage: progress,
          updatedAt: DateTime.now(),
        );
        
        await _databaseHelper.updateLearningGroup(updatedGroup);
      }
    } catch (e) {
      if (e is NotFoundException || e is ArgumentError) {
        rethrow;
      }
      throw RepositoryException('Failed to update video completion: $e');
    }
  }

  @override
  Future<void> reorderVideos(String groupId, List<String> videoIds) async {
    try {
      if (groupId.trim().isEmpty) {
        throw ArgumentError('Group ID cannot be empty');
      }

      if (videoIds.isEmpty) {
        throw ArgumentError('Video IDs list cannot be empty');
      }

      // Get the group
      final group = await _databaseHelper.getLearningGroupById(groupId);
      if (group == null) {
        throw NotFoundException('Group with ID $groupId not found');
      }

      // Validate that all video IDs belong to this group
      final groupVideoIds = group.videos.map((v) => v.id).toSet();
      final providedVideoIds = videoIds.toSet();
      
      if (!groupVideoIds.containsAll(providedVideoIds) || 
          !providedVideoIds.containsAll(groupVideoIds)) {
        throw ValidationException('Video IDs do not match the videos in the group');
      }

      // Create a map for quick lookup
      final videoMap = {for (var video in group.videos) video.id: video};

      // Reorder videos according to the provided order
      final reorderedVideos = <VideoItem>[];
      for (int i = 0; i < videoIds.length; i++) {
        final videoId = videoIds[i];
        final video = videoMap[videoId];
        if (video != null) {
          final updatedVideo = video.copyWith(orderIndex: i);
          reorderedVideos.add(updatedVideo);
        }
      }

      // Update the group with reordered videos
      final updatedGroup = group.copyWith(
        videos: reorderedVideos,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateLearningGroup(updatedGroup);
    } catch (e) {
      if (e is NotFoundException || e is ArgumentError || e is ValidationException) {
        rethrow;
      }
      throw RepositoryException('Failed to reorder videos: $e');
    }
  }

  /// Generate a unique ID for groups and videos
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '${timestamp}_$random';
  }
}

/// Custom exceptions for repository operations
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);
  
  @override
  String toString() => 'RepositoryException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}