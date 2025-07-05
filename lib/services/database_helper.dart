import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Simple method to delete and recreate database
  Future<void> _deleteDatabase() async {
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'fitness_app.db');
      await deleteDatabase(path);
      print('Database deleted: $path');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }

  Future<Database> _initDatabase() async {
    try {
      // Use getDatabasesPath() instead of getApplicationDocumentsDirectory()
      // This ensures we get a writable directory for SQLite
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'fitness_app.db');

      print('Database path: $path'); // Debug

      return await openDatabase(
        path,
        version: 3, // Increased version for profile picture support
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        gender TEXT,
        age INTEGER,
        height REAL,
        weight REAL,
        fitness_goal TEXT,
        profile_picture TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabel Workouts
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories_burned INTEGER,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tabel Exercises
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL,
        duration INTEGER,
        notes TEXT,
        FOREIGN KEY (workout_id) REFERENCES workouts (id)
      )
    ''');

    // Tabel Progress
    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        body_fat_percentage REAL,
        muscle_mass REAL,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tabel AI Analysis
    await db.execute('''
      CREATE TABLE ai_analysis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        workout_id INTEGER,
        analysis_type TEXT NOT NULL,
        pose_data TEXT,
        feedback TEXT,
        score REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (workout_id) REFERENCES workouts (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to users table for profile information
      await db.execute('ALTER TABLE users ADD COLUMN gender TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
      await db.execute('ALTER TABLE users ADD COLUMN height REAL');
      await db.execute('ALTER TABLE users ADD COLUMN weight REAL');
      await db.execute('ALTER TABLE users ADD COLUMN fitness_goal TEXT');
    }
    if (oldVersion < 3) {
      // Add profile picture column
      await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
    }
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> updateUserProfile(int userId, Map<String, dynamic> profileData) async {
    final db = await database;
    profileData['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'users',
      profileData,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['id', 'email', 'name', 'gender', 'age', 'height', 'weight', 'fitness_goal', 'profile_picture', 'created_at', 'updated_at'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  // Workout operations
  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('workouts', workout);
  }

  Future<List<Map<String, dynamic>>> getWorkouts(int userId) async {
    final db = await database;
    return await db.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getWorkout(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  // Exercise operations
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise);
  }

  Future<List<Map<String, dynamic>>> getExercises(int workoutId) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

  // Progress operations
  Future<int> insertProgress(Map<String, dynamic> progress) async {
    final db = await database;
    return await db.insert('progress', progress);
  }

  Future<List<Map<String, dynamic>>> getProgress(int userId) async {
    final db = await database;
    return await db.query(
      'progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // AI Analysis operations
  Future<int> insertAIAnalysis(Map<String, dynamic> analysis) async {
    final db = await database;
    return await db.insert('ai_analysis', analysis);
  }

  Future<List<Map<String, dynamic>>> getAIAnalysis(int userId) async {
    final db = await database;
    return await db.query(
      'ai_analysis',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Delete operations
  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // Reset database (for troubleshooting)
  Future<void> resetDatabase() async {
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'fitness_app.db');

      // Close existing database
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete database file
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      // Reinitialize database
      _database = await _initDatabase();
    } catch (e) {
      print('Database reset error: $e');
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
