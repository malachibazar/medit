import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Database version - increment when schema changes
  static const int _databaseVersion = 2;

  // Get database, initialize if not already done
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  // Create the database tables (fresh install)
  Future<void> _createDb(Database db, int version) async {
    // Notes table with all columns
    await db.execute('''
      CREATE TABLE user_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        note TEXT,
        created_at TEXT,
        updated_at TEXT,
        last_opened_at TEXT,
        is_favorite INTEGER DEFAULT 0,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

    // Folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT,
        created_at TEXT,
        updated_at TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // Create index for faster queries
    await db.execute('CREATE INDEX idx_notes_folder ON user_notes(folder_id)');
    await db.execute(
      'CREATE INDEX idx_notes_favorite ON user_notes(is_favorite)',
    );
    await db.execute(
      'CREATE INDEX idx_notes_last_opened ON user_notes(last_opened_at DESC)',
    );
  }

  // Upgrade database from older versions
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to notes table
      await db.execute('ALTER TABLE user_notes ADD COLUMN last_opened_at TEXT');
      await db.execute('ALTER TABLE user_notes ADD COLUMN folder_id INTEGER');

      // Create folders table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS folders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color TEXT,
          created_at TEXT,
          updated_at TEXT,
          sort_order INTEGER DEFAULT 0
        )
      ''');

      // Create indexes
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_folder ON user_notes(folder_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_favorite ON user_notes(is_favorite)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_last_opened ON user_notes(last_opened_at DESC)',
      );
    }
  }

  // ============================================
  // NOTE CRUD OPERATIONS
  // ============================================

  /// Create - Insert a new note
  Future<int> insertNote(Map<String, dynamic> note) async {
    Database db = await database;
    return await db.insert('user_notes', note);
  }

  /// Read - Get all notes ordered by last update
  Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await database;
    return await db.query('user_notes', orderBy: 'updated_at DESC');
  }

  /// Read - Get a specific note by id
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

  /// Read - Get favorite notes
  Future<List<Map<String, dynamic>>> getFavoriteNotes() async {
    Database db = await database;
    return await db.query(
      'user_notes',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );
  }

  /// Read - Get recent notes (last 10 opened)
  Future<List<Map<String, dynamic>>> getRecentNotes({int limit = 10}) async {
    Database db = await database;
    return await db.query(
      'user_notes',
      where: 'last_opened_at IS NOT NULL',
      orderBy: 'last_opened_at DESC',
      limit: limit,
    );
  }

  /// Read - Get notes by folder
  Future<List<Map<String, dynamic>>> getNotesByFolder(int folderId) async {
    Database db = await database;
    return await db.query(
      'user_notes',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'updated_at DESC',
    );
  }

  /// Read - Get notes without a folder
  Future<List<Map<String, dynamic>>> getNotesWithoutFolder() async {
    Database db = await database;
    return await db.query(
      'user_notes',
      where: 'folder_id IS NULL',
      orderBy: 'updated_at DESC',
    );
  }

  /// Update - Update a note
  Future<int> updateNote(Map<String, dynamic> note) async {
    Database db = await database;
    return await db.update(
      'user_notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  /// Update - Mark note as opened (for recents)
  Future<void> markNoteAsOpened(int noteId) async {
    Database db = await database;
    await db.update(
      'user_notes',
      {'last_opened_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  /// Update - Toggle favorite status
  Future<void> toggleFavorite(int noteId) async {
    Database db = await database;
    final note = await getNote(noteId);
    if (note != null) {
      final isFavorite = note['is_favorite'] == 1;
      await db.update(
        'user_notes',
        {'is_favorite': isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [noteId],
      );
    }
  }

  /// Update - Set note's favorite status
  Future<void> setFavorite(int noteId, bool isFavorite) async {
    Database db = await database;
    await db.update(
      'user_notes',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  /// Update - Move note to folder
  Future<void> moveNoteToFolder(int noteId, int? folderId) async {
    Database db = await database;
    await db.update(
      'user_notes',
      {'folder_id': folderId},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  /// Delete - Delete a note
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete('user_notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all notes
  Future<int> deleteAllNotes() async {
    Database db = await database;
    return await db.delete('user_notes');
  }

  /// Search notes by query - searches both title and note content
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return await getNotes(); // Return all notes if query is empty
    }

    Database db = await database;
    String searchPattern = '%${query.trim()}%';

    return await db.query(
      'user_notes',
      where: 'title LIKE ? OR note LIKE ?',
      whereArgs: [searchPattern, searchPattern],
      orderBy: 'updated_at DESC',
    );
  }

  // ============================================
  // FOLDER CRUD OPERATIONS
  // ============================================

  /// Create - Insert a new folder
  Future<int> insertFolder(Map<String, dynamic> folder) async {
    Database db = await database;
    final now = DateTime.now().toIso8601String();
    folder['created_at'] = now;
    folder['updated_at'] = now;

    // Get the max sort_order and add 1
    final result = await db.rawQuery(
      'SELECT MAX(sort_order) as max_order FROM folders',
    );
    final maxOrder = result.first['max_order'] as int? ?? 0;
    folder['sort_order'] = maxOrder + 1;

    return await db.insert('folders', folder);
  }

  /// Read - Get all folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    Database db = await database;
    return await db.query('folders', orderBy: 'sort_order ASC');
  }

  /// Read - Get a specific folder by id
  Future<Map<String, dynamic>?> getFolder(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Read - Get note count for a folder
  Future<int> getFolderNoteCount(int folderId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_notes WHERE folder_id = ?',
      [folderId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Update - Update a folder
  Future<int> updateFolder(Map<String, dynamic> folder) async {
    Database db = await database;
    folder['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'folders',
      folder,
      where: 'id = ?',
      whereArgs: [folder['id']],
    );
  }

  /// Update - Reorder folders
  Future<void> reorderFolders(List<int> folderIds) async {
    Database db = await database;
    for (int i = 0; i < folderIds.length; i++) {
      await db.update(
        'folders',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [folderIds[i]],
      );
    }
  }

  /// Delete - Delete a folder (notes will have folder_id set to NULL)
  Future<int> deleteFolder(int id) async {
    Database db = await database;
    // First, set folder_id to NULL for all notes in this folder
    await db.update(
      'user_notes',
      {'folder_id': null},
      where: 'folder_id = ?',
      whereArgs: [id],
    );
    // Then delete the folder
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get total note count
  Future<int> getNoteCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_notes',
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Get favorite note count
  Future<int> getFavoriteNoteCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_notes WHERE is_favorite = 1',
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Get recent note count (notes opened at least once)
  Future<int> getRecentNoteCount({int limit = 10}) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM (SELECT id FROM user_notes WHERE last_opened_at IS NOT NULL ORDER BY last_opened_at DESC LIMIT ?)',
      [limit],
    );
    return result.first['count'] as int? ?? 0;
  }
}
