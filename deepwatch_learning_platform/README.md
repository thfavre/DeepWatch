# DeepWatch Learning Platform

Transform YouTube videos into structured learning experiences with AI-powered flashcards, focus modes, and progress tracking.

## Features

- **Learning Groups**: Organize YouTube videos into structured collections
- **Integrated Note-Taking**: Markdown-based notes with auto-save functionality
- **Focus Mode**: Device locking for distraction-free learning sessions
- **AI-Powered Flashcards**: Generate flashcards from notes and video content
- **Spaced Repetition**: Smart review scheduling using SM2 algorithm
- **Progress Tracking**: Comprehensive learning analytics and achievements
- **Cross-Platform**: Single codebase for iOS, Android, and Web

## Project Structure

```
lib/
├── models/          # Data models and entities
├── services/        # Business logic and external API integrations
├── repositories/    # Data access layer and storage management
├── widgets/         # Reusable UI components
├── screens/         # Application screens and pages
└── main.dart        # Application entry point
```

## Dependencies

- **flutter_riverpod**: State management
- **youtube_player_flutter**: YouTube video integration
- **markdown**: Markdown processing and rendering
- **sqflite**: Local database storage
- **firebase_core**: Backend services and synchronization

## Getting Started

1. Ensure Flutter is installed and configured
2. Run `flutter pub get` to install dependencies
3. For web development: `flutter run -d chrome`
4. For mobile development: `flutter run`

## Platform Support

- ✅ iOS (iPhone/iPad)
- ✅ Android (Phone/Tablet)
- ✅ Web (Desktop/Mobile browsers)

## Development

This project follows the spec-driven development methodology with comprehensive requirements, design documentation, and implementation tasks defined in `.kiro/specs/deepwatch-learning-platform/`.
