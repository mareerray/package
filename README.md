# Secure Notes: Package-Based Architecture

This project refactors the Secure Notes app. It pulls out database and model logic into a standalone Dart package. This makes storage modular for reuse in many Flutter apps.

![package](secure_notes/assets/images/package.png)

## Project Structure
The project has a core package and a Flutter app that uses it.

```
├── note/                       # Reusable Dart Package
│   ├── lib/
│   │   ├── note.dart           # Public API (exports Note and Database classes)
│   │   └── src/                # Internal implementation
│   │       ├── database.dart   # SQLite CRUD operations
│   │       └── note.dart       # Note model class
│   └── pubspec.yaml            # Package dependencies (e.g., sqflite)
│
└── secure_notes/               # Flutter Application
    ├── lib/
    │   ├── main.dart           # App entry point
    │   ├── note_list_screen.dart # UI for viewing/deleting notes
    │   └── edit_screen.dart    # UI for adding/editing notes
    └── pubspec.yaml            # References 'note' via relative path
```

## The note Package
Made with `flutter create --template=package note`. It handles only database logic. No UI.

1. Note Model Class
Note class holds one note's data:

    - id: Unique number (can be null).

    - title: Note title (String).

    - body: Note content (String).

    - date: When made (String).

Helpers: toMap() for saving, fromMap() for loading.

2. Database Functionality
NotesDatabase class uses sqflite for SQLite. Table is "Note". Operations:

    - getAllNotes(): Get all notes.

    - addNote(note): Add new note.

    - updateNote(oldNote, newNote): Change note.

    - deleteNote(note): Remove note.

    - deleteAllNotes(): Clear all.

## Integration & Usage
Dependency Management
In secure_notes pubspec.yaml:

```
dependencies:
  note:
    path: ../note
```

Public API
Import simply:

```dart
import 'package:note/note.dart';
```

## Learning Objectives
- Build reusable Dart package with public API.

- Make database layer with sqflite.

- Create model classes for data.

- Understand package structure and local dependencies.

## Author
[Mayuree Reunsati](https://github.com/mareerray)

March 2026