import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'health_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account TEXT UNIQUE,
            password TEXT,
            name TEXT,
            birthday TEXT,
            height REAL,
            weight REAL
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final database = await db;
    return await database.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String account) async {
    final database = await db;
    final res =
    await database.query('users', where: 'account = ?', whereArgs: [account]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<int> updateUser(String account, Map<String, dynamic> data) async {
    final database = await db;
    return await database
        .update('users', data, where: 'account = ?', whereArgs: [account]);
  }
}