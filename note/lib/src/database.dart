import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqf;

import 'note_model.dart';

class NotesDatabase {
  static const _dbName = 'secure_notes.db';
  static const _dbVersion = 1;
  static const _tableName = 'Note';

  sqf.Database? _db;

  Future<sqf.Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<sqf.Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, _dbName);

    return await sqf.openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Retrieve all notes from the database
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'id DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  // Insert a new note into the database
  Future<int> addNote({required Note note}) async {
    final db = await database;
    return await db.insert(_tableName, note.toMap());
  }

  // Modify an existing note in the database
  Future<int> updateNote({
    required Note oldNote,
    required Note newNote,
  }) async {
    if (oldNote.id == null) {
      throw ArgumentError('oldNote.id is null, cannot update');
    }

    final db = await database;
    return await db.update(
      _tableName,
      newNote.toMap(),
      where: 'id = ?',
      whereArgs: [oldNote.id],
    );
  }

  // Remove a specific note from the database
  Future<int> deleteNote({required Note note}) async {
    if (note.id == null) {
      throw ArgumentError('note.id is null, cannot delete');
    }

    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Clear all notes from the database
  Future<int> deleteAllNotes() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  Future close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}