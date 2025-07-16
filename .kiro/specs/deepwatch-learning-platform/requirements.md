# Requirements Document

## Introduction

DeepWatch is a comprehensive learning platform that transforms YouTube videos into structured learning experiences with AI-powered flashcards, focus modes, and progress tracking. The platform targets both mobile (iOS/Android) and web users through a single Flutter codebase, enabling users to create learning groups, take notes, generate flashcards, and track their learning progress across devices.

## Requirements

### Requirement 1

**User Story:** As a learner, I want to create and manage learning groups with YouTube videos, so that I can organize my educational content into structured collections.

#### Acceptance Criteria

1. WHEN a user clicks the "+ New Group" button THEN the system SHALL display a form to create a new learning group
2. WHEN a user provides a group name and YouTube links THEN the system SHALL create the group and validate the YouTube URLs
3. WHEN a user views the home page THEN the system SHALL display all learning groups with name, video count, and progress percentage
4. WHEN a user selects a learning group THEN the system SHALL navigate to the group detail page showing all videos
5. IF a YouTube URL is invalid THEN the system SHALL display an error message and prevent group creation

### Requirement 2

**User Story:** As a learner, I want to watch YouTube videos with integrated note-taking capabilities, so that I can capture important information while learning.

#### Acceptance Criteria

1. WHEN a user selects a video THEN the system SHALL display an embedded YouTube player with a markdown notes section
2. WHEN a user types in the notes section THEN the system SHALL auto-save notes every 30 seconds
3. WHEN a user switches between videos THEN the system SHALL preserve and restore video-specific notes
4. WHEN a user adjusts playback speed THEN the system SHALL maintain the setting across video sessions
5. WHEN a user toggles light/dark mode THEN the system SHALL apply the theme to all UI components

### Requirement 3

**User Story:** As a learner, I want a hardcore focus mode that locks my device, so that I can maintain concentration during study sessions without distractions.

#### Acceptance Criteria

1. WHEN a user activates focus mode THEN the system SHALL lock the device interface and display only the video and notes
2. WHEN focus mode is active THEN the system SHALL show a countdown timer for the selected duration (20/40/60 minutes)
3. WHEN the focus timer expires THEN the system SHALL automatically exit focus mode and show completion notification
4. WHEN a user needs emergency access THEN the system SHALL provide an emergency unlock button
5. IF a user tries to switch apps during focus mode THEN the system SHALL prevent app switching and return to DeepWatch

### Requirement 4

**User Story:** As a learner, I want AI-generated flashcards based on my notes and video content, so that I can reinforce my learning through spaced repetition.

#### Acceptance Criteria

1. WHEN a video ends or is marked complete THEN the system SHALL prompt the user for reflection questions
2. WHEN a user completes reflection prompts THEN the system SHALL generate 3-5 flashcards using AI based on notes and transcript
3. WHEN flashcards are generated THEN the system SHALL allow users to edit, save, or add manual flashcards
4. WHEN a user reviews flashcards THEN the system SHALL implement spaced repetition algorithm (SM2)
5. WHEN a user rates flashcard difficulty THEN the system SHALL adjust the review schedule accordingly

### Requirement 5

**User Story:** As a learner, I want to practice flashcards in different modes, so that I can review content by group, video, or random selection.

#### Acceptance Criteria

1. WHEN a user accesses the flashcard center THEN the system SHALL offer review modes: by group, by video, and random shuffle
2. WHEN a user selects a review mode THEN the system SHALL display flashcards with swipe/tap-to-reveal functionality
3. WHEN a user reviews a flashcard THEN the system SHALL provide options to show source notes and rate confidence
4. WHEN a user completes a flashcard session THEN the system SHALL update progress tracking and schedule next reviews
5. WHEN a user wants to see flashcard source THEN the system SHALL display the original notes and video timestamp

### Requirement 6

**User Story:** As a learner, I want to track my progress across groups and videos, so that I can monitor my learning achievements and identify areas needing attention.

#### Acceptance Criteria

1. WHEN a user views any learning group THEN the system SHALL display progress bars for individual videos and overall group completion
2. WHEN a user completes a video THEN the system SHALL update the progress percentage and mark the video as complete
3. WHEN a user reviews flashcards THEN the system SHALL track review sessions and update learning statistics
4. WHEN a user accesses their profile THEN the system SHALL display comprehensive learning analytics and achievements
5. WHEN progress is updated THEN the system SHALL sync data across all user devices

### Requirement 7

**User Story:** As a learner, I want to organize and customize my learning content, so that I can maintain an efficient and personalized learning environment.

#### Acceptance Criteria

1. WHEN a user views a learning group THEN the system SHALL allow drag-to-reorder videos within the group
2. WHEN a user wants to edit content THEN the system SHALL provide options to rename groups, delete groups, and manage video lists
3. WHEN a user creates flashcards THEN the system SHALL allow manual creation, editing, and organization with tags
4. WHEN a user applies filters THEN the system SHALL sort groups by recent, alphabetical, or progress criteria
5. WHEN a user manages tags THEN the system SHALL auto-suggest tags and allow custom tag creation

### Requirement 8

**User Story:** As a learner, I want the platform to work seamlessly across mobile and web devices, so that I can continue my learning regardless of the device I'm using.

#### Acceptance Criteria

1. WHEN a user accesses DeepWatch on any device THEN the system SHALL provide a responsive UI optimized for that platform
2. WHEN a user switches between devices THEN the system SHALL sync all data including notes, progress, and flashcards
3. WHEN a user uses the web version THEN the system SHALL provide desktop-optimized features like keyboard shortcuts
4. WHEN a user uses the mobile version THEN the system SHALL provide touch-optimized interactions and gestures
5. WHEN network connectivity is poor THEN the system SHALL provide offline access to downloaded content and sync when reconnected