import 'package:deepwatch_learning_platform/models/learning_group.dart';
import 'package:deepwatch_learning_platform/models/video_item.dart';

/// Abstract repository interface for learning group operations
abstract class LearningGroupRepository {
  /// Get all learning groups ordered by most recently updated
  Future<List<LearningGroup>> getAllGroups();

  /// Get a specific learning group by ID
  Future<LearningGroup?> getGroupById(String id);

  /// Create a new learning group with YouTube URLs
  Future<LearningGroup> createGroup(String name, List<String> youtubeUrls);

  /// Update an existing learning group
  Future<void> updateGroup(LearningGroup group);

  /// Delete a learning group by ID
  Future<void> deleteGroup(String id);

  /// Calculate progress percentage for a group based on completed videos
  double calculateGroupProgress(List<VideoItem> videos);

  /// Update video completion status and recalculate group progress
  Future<void> updateVideoCompletion(String groupId, String videoId, bool isCompleted);

  /// Reorder videos within a group
  Future<void> reorderVideos(String groupId, List<String> videoIds);
}