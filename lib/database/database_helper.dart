import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dfd.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'dfd_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE dfds(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT NOT NULL,
            dataDfd TEXT NOT NULL,
            dataCriacao TEXT NOT NULL,
            justificativa TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertDfd(Dfd dfd) async {
    final db = await database;
    return db.insert('dfds', dfd.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // READ ALL
  Future<List<Dfd>> getAllDfds() async {
    final db = await database;
    final maps = await db.query('dfds', orderBy: 'id DESC');
    return maps.map((m) => Dfd.fromMap(m)).toList();
  }

  // READ com busca por código ou justificativa
  Future<List<Dfd>> searchDfds(String query) async {
    final db = await database;
    final maps = await db.query(
      'dfds',
      where: 'codigo LIKE ? OR justificativa LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Dfd.fromMap(m)).toList();
  }

  // UPDATE
  Future<void> updateDfd(Dfd dfd) async {
    final db = await database;
    await db.update(
      'dfds',
      dfd.toMap(),
      where: 'id = ?',
      whereArgs: [dfd.id],
    );
  }

  // DELETE
  Future<void> deleteDfd(int id) async {
    final db = await database;
    await db.delete('dfds', where: 'id = ?', whereArgs: [id]);
  }
}