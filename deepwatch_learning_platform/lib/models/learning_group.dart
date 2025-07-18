import 'package:equatable/equatable.dart';
import 'package:deepwatch_learning_platform/models/video_item.dart';

class LearningGroup extends Equatable {
  final String id;
  final String name;
  final List<VideoItem> videos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double progressPercentage;
  final Map<String, String> metadata;

  const LearningGroup({
    required this.id,
    required this.name,
    required this.videos,
    required this.createdAt,
    required this.updatedAt,
    required this.progressPercentage,
    required this.metadata,
  });

  // Validation method
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Group name is required';
    }
    if (name.trim().length < 2) {
      return 'Group name must be at least 2 characters';
    }
    if (name.trim().length > 100) {
      return 'Group name must be less than 100 characters';
    }
    return null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'videos': videos.map((video) => video.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'progressPercentage': progressPercentage,
      'metadata': metadata,
    };
  }

  // JSON deserialization
  factory LearningGroup.fromJson(Map<String, dynamic> json) {
    return LearningGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      videos: (json['videos'] as List<dynamic>)
          .map((videoJson) => VideoItem.fromJson(videoJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      metadata: Map<String, String>.from(json['metadata'] as Map),
    );
  }

  // Copy with method for immutability
  LearningGroup copyWith({
    String? id,
    String? name,
    List<VideoItem>? videos,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? progressPercentage,
    Map<String, String>? metadata,
  }) {
    return LearningGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      videos: videos ?? this.videos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, name, videos, createdAt, updatedAt, progressPercentage, metadata];
}