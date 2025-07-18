import 'package:equatable/equatable.dart';

enum FocusMode {
  light,
  hardcore,
}

class FocusSession extends Equatable {
  final String id;
  final Duration duration;
  final DateTime startTime;
  final String videoId;
  final bool isActive;
  final FocusMode mode;
  final DateTime? endTime;
  final bool wasCompleted;

  const FocusSession({
    required this.id,
    required this.duration,
    required this.startTime,
    required this.videoId,
    required this.isActive,
    required this.mode,
    this.endTime,
    required this.wasCompleted,
  });

  // Validation methods
  static String? validateDuration(Duration? duration) {
    if (duration == null) {
      return 'Duration is required';
    }
    if (duration.inMinutes < 5) {
      return 'Focus session must be at least 5 minutes';
    }
    if (duration.inMinutes > 180) {
      return 'Focus session cannot exceed 3 hours';
    }
    return null;
  }

  static String? validateVideoId(String? videoId) {
    if (videoId == null || videoId.trim().isEmpty) {
      return 'Video ID is required for focus session';
    }
    return null;
  }

  // Calculate remaining time
  Duration get remainingTime {
    if (!isActive || endTime != null) {
      return Duration.zero;
    }
    
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Calculate elapsed time
  Duration get elapsedTime {
    final endTimeToUse = endTime ?? DateTime.now();
    return endTimeToUse.difference(startTime);
  }

  // Check if session is expired
  bool get isExpired {
    if (!isActive) return false;
    return DateTime.now().isAfter(startTime.add(duration));
  }

  // Calculate completion percentage
  double get completionPercentage {
    final elapsed = elapsedTime;
    if (elapsed >= duration) return 1.0;
    return elapsed.inMilliseconds / duration.inMilliseconds;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration.inSeconds,
      'startTime': startTime.toIso8601String(),
      'videoId': videoId,
      'isActive': isActive,
      'mode': mode.name,
      'endTime': endTime?.toIso8601String(),
      'wasCompleted': wasCompleted,
    };
  }

  // JSON deserialization
  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      duration: Duration(seconds: json['duration'] as int),
      startTime: DateTime.parse(json['startTime'] as String),
      videoId: json['videoId'] as String,
      isActive: json['isActive'] as bool,
      mode: FocusMode.values.firstWhere(
        (mode) => mode.name == json['mode'],
        orElse: () => FocusMode.light,
      ),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String)
          : null,
      wasCompleted: json['wasCompleted'] as bool,
    );
  }

  // Copy with method for immutability
  FocusSession copyWith({
    String? id,
    Duration? duration,
    DateTime? startTime,
    String? videoId,
    bool? isActive,
    FocusMode? mode,
    DateTime? endTime,
    bool? wasCompleted,
  }) {
    return FocusSession(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      videoId: videoId ?? this.videoId,
      isActive: isActive ?? this.isActive,
      mode: mode ?? this.mode,
      endTime: endTime ?? this.endTime,
      wasCompleted: wasCompleted ?? this.wasCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        duration,
        startTime,
        videoId,
        isActive,
        mode,
        endTime,
        wasCompleted,
      ];
}