import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Get database, initialize if not already done
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  // Create the database tables
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        note TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');
  }

  // CRUD Operations

  // Create - Insert a new note
  Future<int> insertNote(Map<String, dynamic> note) async {
    Database db = await database;
    return await db.insert('user_notes', note);
  }

  // Read - Get all notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await database;
    return await db.query('user_notes', orderBy: 'updated_at DESC');
  }

  // Read - Get a specific note by id
  Future<Map<String, dynamic>?> getNote(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'user_notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Update - Update a note
  Future<int> updateNote(Map<String, dynamic> note) async {
    Database db = await database;
    return await db.update(
      'user_notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  // Delete - Delete a note
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete('user_notes', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all notes
  Future<int> deleteAllNotes() async {
    Database db = await database;
    return await db.delete('user_notes');
  }
}
