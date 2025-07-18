import 'package:equatable/equatable.dart';

class VideoItem extends Equatable {
  final String id;
  final String youtubeId;
  final String title;
  final String thumbnailUrl;
  final Duration duration;
  final bool isCompleted;
  final String notes;
  final List<String> tags;
  final DateTime lastWatched;
  final int orderIndex;

  const VideoItem({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.isCompleted,
    required this.notes,
    required this.tags,
    required this.lastWatched,
    required this.orderIndex,
  });

  // YouTube URL validation
  static String? validateYouTubeUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'YouTube URL is required';
    }

    final trimmedUrl = url.trim();
    
    // YouTube URL patterns
    final patterns = [
      RegExp(r'^https?:\/\/(www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?:\/\/(www\.)?youtube\.com\/embed\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?:\/\/youtu\.be\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?:\/\/(www\.)?youtube\.com\/v\/([a-zA-Z0-9_-]{11})'),
    ];

    bool isValid = patterns.any((pattern) => pattern.hasMatch(trimmedUrl));
    
    if (!isValid) {
      return 'Please enter a valid YouTube URL';
    }
    
    return null;
  }

  // Extract YouTube ID from URL
  static String? extractYouTubeId(String url) {
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)([a-zA-Z0-9_-]{11})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }

  // Validation method for title
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Video title is required';
    }
    if (title.trim().length > 200) {
      return 'Video title must be less than 200 characters';
    }
    return null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtubeId': youtubeId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration.inSeconds,
      'isCompleted': isCompleted,
      'notes': notes,
      'tags': tags,
      'lastWatched': lastWatched.toIso8601String(),
      'orderIndex': orderIndex,
    };
  }

  // JSON deserialization
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      youtubeId: json['youtubeId'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      duration: Duration(seconds: json['duration'] as int),
      isCompleted: json['isCompleted'] as bool,
      notes: json['notes'] as String,
      tags: List<String>.from(json['tags'] as List),
      lastWatched: DateTime.parse(json['lastWatched'] as String),
      orderIndex: json['orderIndex'] as int,
    );
  }

  // Copy with method for immutability
  VideoItem copyWith({
    String? id,
    String? youtubeId,
    String? title,
    String? thumbnailUrl,
    Duration? duration,
    bool? isCompleted,
    String? notes,
    List<String>? tags,
    DateTime? lastWatched,
    int? orderIndex,
  }) {
    return VideoItem(
      id: id ?? this.id,
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      lastWatched: lastWatched ?? this.lastWatched,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        youtubeId,
        title,
        thumbnailUrl,
        duration,
        isCompleted,
        notes,
        tags,
        lastWatched,
        orderIndex,
      ];
}