# AGENTS.md - Medit Codebase Guide

This document provides guidelines for AI agents working on the Medit codebase.

## Project Overview

Medit is a Flutter desktop note-taking application with Markdown support. It uses Cupertino widgets for a native macOS aesthetic and SQLite for local storage.

- **Language:** Dart (SDK ^3.7.0)
- **Framework:** Flutter (>= 3.24.0)
- **Primary Target:** macOS (also supports iOS, Android, Linux, Windows, Web)
- **UI Toolkit:** Cupertino widgets (iOS/macOS native design)
- **Database:** SQLite via `sqflite` package

## Build/Lint/Test Commands

### Install Dependencies
```bash
flutter pub get
```

### Run Application
```bash
flutter run -d macos      # macOS (primary)
flutter run -d ios        # iOS simulator
flutter run -d chrome     # Web
```

### Lint/Analyze
```bash
flutter analyze           # Run static analysis
dart format .             # Format all Dart files
dart format --set-exit-if-changed .  # Check formatting (CI)
```

### Run Tests
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run a specific test by name
flutter test --name "App launches successfully"

# Run with verbose output
flutter test --reporter expanded

# Run with coverage
flutter test --coverage
```

### Build for Release
```bash
flutter build macos       # macOS release build
flutter build ios         # iOS release build
flutter build apk         # Android APK
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── database_helper.dart      # SQLite database operations (singleton)
├── app/                      # App configuration
│   ├── app.dart              # Root MeditApp widget
│   └── theme/                # Theme system
│       ├── app_colors.dart   # Color definitions (light/dark)
│       └── app_theme.dart    # Theme helpers and text styles
├── models/                   # Data models
├── screens/                  # Screen widgets
│   └── home_screen.dart      # Main three-column layout
├── services/                 # Business logic (currently empty)
└── widgets/                  # Reusable UI components
    ├── command_palette/
    ├── editor/
    ├── keyboard_shortcuts/
    ├── notes_list/
    └── sidebar/
```

## Code Style Guidelines

### File & Naming Conventions
- **Files:** snake_case (`note_editor.dart`, `app_colors.dart`)
- **Classes:** PascalCase (`NoteEditor`, `DatabaseHelper`)
- **Variables/Functions:** camelCase (`_selectedNoteId`, `_loadNotes()`)
- **Private members:** Prefix with underscore (`_database`, `_initDatabase()`)
- **Constants:** camelCase or SCREAMING_SNAKE_CASE for compile-time constants

### Imports
Order imports in this sequence:
1. Dart SDK (`dart:async`, `dart:io`)
2. Flutter packages (`package:flutter/cupertino.dart`)
3. External packages (`package:sqflite/sqflite.dart`)
4. Local imports with relative paths (`../app/theme/app_theme.dart`)

```dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import '../../app/theme/app_theme.dart';
import '../../database_helper.dart';
```

### Widget Patterns
- Use `StatefulWidget` with explicit State class naming (e.g., `NoteEditorState`)
- Make State classes public when parent needs access to methods
- Use `GlobalKey<WidgetState>` for parent-to-child communication
- Prefer Cupertino widgets over Material widgets

```dart
class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.noteId});
  final int noteId;
  
  @override
  State<NoteEditor> createState() => NoteEditorState();
}

class NoteEditorState extends State<NoteEditor> {
  // Public methods for parent access
  void focusContent() => _contentFocusNode.requestFocus();
}
```

### Documentation
- Use `///` doc comments for public APIs
- Use section separators for code organization:
```dart
// ============================================
// SECTION NAME
// ============================================
```

### Method Naming Conventions
- Event handlers: `_on<Event>` (e.g., `_onNoteSelected`, `_onSearchChanged`)
- Build methods: `_build<Section>` (e.g., `_buildSidebar`, `_buildEditor`)
- Async methods: Return `Future<T>` or `Future<void>`

### Theme & Colors
- All colors defined in `AppColors` class (`lib/app/theme/app_colors.dart`)
- Use semantic color names (`darkTextPrimary`, `lightContentBg`)
- Access theme values via `AppTheme` helpers: `AppTheme.textPrimary(context)`
- Support both light and dark mode automatically

### Error Handling
- Use null safety (`?`, `!`, `??`)
- Check `mounted` before calling `setState` in async callbacks
- Use early returns for guard clauses

```dart
Future<void> _loadData() async {
  if (!mounted) return;
  final data = await fetchData();
  if (mounted) {
    setState(() => _data = data);
  }
}
```

### State Management
- Use basic `setState` (no external state management library)
- Pass callbacks up for parent communication
- Pass data down through widget constructor

### Database Operations
- `DatabaseHelper` is a singleton (access via `DatabaseHelper()`)
- All CRUD methods are async and return Futures
- Use ISO 8601 strings for timestamps

### Async Patterns
- Use `Future.wait()` for parallel async operations
- Use `Timer` for debouncing (e.g., auto-save)
- Cancel timers in `dispose()`

```dart
Timer? _saveTimer;

void _onContentChanged() {
  _saveTimer?.cancel();
  _saveTimer = Timer(const Duration(seconds: 1), _autoSave);
}

@override
void dispose() {
  _saveTimer?.cancel();
  super.dispose();
}
```

### Keyboard Shortcuts
- Check for `KeyDownEvent` only (ignore KeyUp)
- Use `HardwareKeyboard.instance.isMetaPressed` for modifier keys
- Return `KeyEventResult.handled` when consuming events

### Testing
- Test files go in `test/` directory
- Use `flutter_test` package
- Widget tests use `WidgetTester` and `pumpWidget`

```dart
testWidgets('description', (WidgetTester tester) async {
  await tester.pumpWidget(const MeditApp());
  expect(find.textContaining('note'), findsWidgets);
});
```

## Key Dependencies
- `sqflite: ^2.4.2` - SQLite database
- `flutter_markdown: ^0.6.18` - Markdown rendering
- `file_picker: ^6.2.0` - File picking
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^5.0.0` - Linting rules
