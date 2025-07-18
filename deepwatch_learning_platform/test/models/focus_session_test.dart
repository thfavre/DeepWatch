import 'package:flutter_test/flutter_test.dart';
import 'package:deepwatch_learning_platform/models/focus_session.dart';

void main() {
  group('FocusSession', () {
    late FocusSession testFocusSession;

    setUp(() {
      testFocusSession = FocusSession(
        id: 'session-1',
        duration: const Duration(minutes: 25),
        startTime: DateTime(2024, 1, 1, 10, 0),
        videoId: 'video-1',
        isActive: true,
        mode: FocusMode.hardcore,
        endTime: null,
        wasCompleted: false,
      );
    });

    group('Duration Validation', () {
      test('should accept valid durations', () {
        expect(FocusSession.validateDuration(const Duration(minutes: 20)), isNull);
        expect(FocusSession.validateDuration(const Duration(minutes: 60)), isNull);
        expect(FocusSession.validateDuration(const Duration(minutes: 180)), isNull);
      });

      test('should reject null duration', () {
        expect(FocusSession.validateDuration(null), isNotNull);
      });

      test('should reject durations that are too short', () {
        expect(FocusSession.validateDuration(const Duration(minutes: 4)), isNotNull);
        expect(FocusSession.validateDuration(const Duration(minutes: 1)), isNotNull);
      });

      test('should reject durations that are too long', () {
        expect(FocusSession.validateDuration(const Duration(minutes: 181)), isNotNull);
        expect(FocusSession.validateDuration(const Duration(hours: 4)), isNotNull);
      });
    });

    group('Video ID Validation', () {
      test('should accept valid video IDs', () {
        expect(FocusSession.validateVideoId('video-123'), isNull);
        expect(FocusSession.validateVideoId('abc-def-ghi'), isNull);
      });

      test('should reject empty video IDs', () {
        expect(FocusSession.validateVideoId(''), isNotNull);
        expect(FocusSession.validateVideoId(null), isNotNull);
        expect(FocusSession.validateVideoId('   '), isNotNull);
      });
    });

    group('Time Calculations', () {
      test('should calculate remaining time correctly for active session', () {
        // Create a session that started 10 minutes ago
        final startTime = DateTime.now().subtract(const Duration(minutes: 10));
        final session = testFocusSession.copyWith(
          startTime: startTime,
          duration: const Duration(minutes: 25),
        );

        final remaining = session.remainingTime;
        
        // Should have approximately 15 minutes remaining (allowing for test execution time)
        expect(remaining.inMinutes, greaterThanOrEqualTo(14));
        expect(remaining.inMinutes, lessThanOrEqualTo(15));
      });

      test('should return zero remaining time for completed session', () {
        final completedSession = testFocusSession.copyWith(
          isActive: false,
          endTime: DateTime(2024, 1, 1, 10, 25),
        );

        expect(completedSession.remainingTime, equals(Duration.zero));
      });

      test('should return zero remaining time for expired session', () {
        // Create a session that started 30 minutes ago with 25 minute duration
        final startTime = DateTime.now().subtract(const Duration(minutes: 30));
        final session = testFocusSession.copyWith(
          startTime: startTime,
          duration: const Duration(minutes: 25),
        );

        expect(session.remainingTime, equals(Duration.zero));
      });

      test('should calculate elapsed time correctly', () {
        final session = FocusSession(
          id: 'session-1',
          duration: const Duration(minutes: 25),
          startTime: DateTime(2024, 1, 1, 10, 0),
          videoId: 'video-1',
          isActive: false,
          mode: FocusMode.hardcore,
          endTime: DateTime(2024, 1, 1, 10, 15), // 15 minutes later
          wasCompleted: true,
        );

        expect(session.elapsedTime, equals(const Duration(minutes: 15)));
      });
    });

    group('Session Status', () {
      test('should detect expired session', () {
        // Create a session that started 30 minutes ago with 25 minute duration
        final startTime = DateTime.now().subtract(const Duration(minutes: 30));
        final session = testFocusSession.copyWith(
          startTime: startTime,
          duration: const Duration(minutes: 25),
        );

        expect(session.isExpired, isTrue);
      });

      test('should not be expired for inactive session', () {
        final inactiveSession = testFocusSession.copyWith(isActive: false);
        expect(inactiveSession.isExpired, isFalse);
      });

      test('should not be expired for active session within duration', () {
        // Create a session that started 10 minutes ago with 25 minute duration
        final startTime = DateTime.now().subtract(const Duration(minutes: 10));
        final session = testFocusSession.copyWith(
          startTime: startTime,
          duration: const Duration(minutes: 25),
        );

        expect(session.isExpired, isFalse);
      });

      test('should calculate completion percentage correctly', () {
        final session = FocusSession(
          id: 'session-1',
          duration: const Duration(minutes: 20),
          startTime: DateTime(2024, 1, 1, 10, 0),
          videoId: 'video-1',
          isActive: false,
          mode: FocusMode.hardcore,
          endTime: DateTime(2024, 1, 1, 10, 10), // 10 minutes later
          wasCompleted: false,
        );

        expect(session.completionPercentage, equals(0.5)); // 50%
      });

      test('should cap completion percentage at 100%', () {
        final session = FocusSession(
          id: 'session-1',
          duration: const Duration(minutes: 20),
          startTime: DateTime(2024, 1, 1, 10, 0),
          videoId: 'video-1',
          isActive: false,
          mode: FocusMode.hardcore,
          endTime: DateTime(2024, 1, 1, 10, 30), // 30 minutes later (150%)
          wasCompleted: true,
        );

        expect(session.completionPercentage, equals(1.0)); // 100%
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testFocusSession.toJson();

        expect(json['id'], equals('session-1'));
        expect(json['duration'], equals(1500)); // 25 minutes in seconds
        expect(json['startTime'], equals('2024-01-01T10:00:00.000'));
        expect(json['videoId'], equals('video-1'));
        expect(json['isActive'], equals(true));
        expect(json['mode'], equals('hardcore'));
        expect(json['endTime'], isNull);
        expect(json['wasCompleted'], equals(false));
      });

      test('should serialize with endTime when present', () {
        final sessionWithEndTime = testFocusSession.copyWith(
          endTime: DateTime(2024, 1, 1, 10, 25),
        );
        
        final json = sessionWithEndTime.toJson();
        expect(json['endTime'], equals('2024-01-01T10:25:00.000'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'session-1',
          'duration': 1500,
          'startTime': '2024-01-01T10:00:00.000',
          'videoId': 'video-1',
          'isActive': true,
          'mode': 'hardcore',
          'endTime': null,
          'wasCompleted': false,
        };

        final session = FocusSession.fromJson(json);

        expect(session.id, equals('session-1'));
        expect(session.duration, equals(const Duration(minutes: 25)));
        expect(session.startTime, equals(DateTime(2024, 1, 1, 10, 0)));
        expect(session.videoId, equals('video-1'));
        expect(session.isActive, equals(true));
        expect(session.mode, equals(FocusMode.hardcore));
        expect(session.endTime, isNull);
        expect(session.wasCompleted, equals(false));
      });

      test('should handle unknown focus mode gracefully', () {
        final json = {
          'id': 'session-1',
          'duration': 1500,
          'startTime': '2024-01-01T10:00:00.000',
          'videoId': 'video-1',
          'isActive': true,
          'mode': 'unknown_mode',
          'endTime': null,
          'wasCompleted': false,
        };

        final session = FocusSession.fromJson(json);
        expect(session.mode, equals(FocusMode.light)); // Should default to light
      });

      test('should maintain data integrity through serialization round-trip', () {
        final json = testFocusSession.toJson();
        final deserializedSession = FocusSession.fromJson(json);

        expect(deserializedSession, equals(testFocusSession));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedSession = testFocusSession.copyWith(
          duration: const Duration(minutes: 45),
          isActive: false,
          wasCompleted: true,
        );

        expect(updatedSession.duration, equals(const Duration(minutes: 45)));
        expect(updatedSession.isActive, equals(false));
        expect(updatedSession.wasCompleted, equals(true));
        expect(updatedSession.id, equals(testFocusSession.id));
        expect(updatedSession.videoId, equals(testFocusSession.videoId));
      });

      test('should create identical copy when no fields are updated', () {
        final copiedSession = testFocusSession.copyWith();

        expect(copiedSession, equals(testFocusSession));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final session1 = FocusSession(
          id: 'session-1',
          duration: const Duration(minutes: 25),
          startTime: DateTime(2024, 1, 1, 10, 0),
          videoId: 'video-1',
          isActive: true,
          mode: FocusMode.hardcore,
          endTime: null,
          wasCompleted: false,
        );

        final session2 = FocusSession(
          id: 'session-1',
          duration: const Duration(minutes: 25),
          startTime: DateTime(2024, 1, 1, 10, 0),
          videoId: 'video-1',
          isActive: true,
          mode: FocusMode.hardcore,
          endTime: null,
          wasCompleted: false,
        );

        expect(session1, equals(session2));
        expect(session1.hashCode, equals(session2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final session2 = testFocusSession.copyWith(duration: const Duration(minutes: 45));

        expect(testFocusSession, isNot(equals(session2)));
      });
    });
  });
}