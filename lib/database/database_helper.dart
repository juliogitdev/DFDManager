import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dfd.dart';

class DfdStats {
  final int total;
  final int cadastradasNoMes;
  final DateTime? ultimaAtualizacao;

  const DfdStats({
    required this.total,
    required this.cadastradasNoMes,
    required this.ultimaAtualizacao,
  });
}

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dfds(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT NOT NULL,
            dataDfd TEXT NOT NULL,
            dataCriacao TEXT NOT NULL,
            justificativa TEXT NOT NULL,
            updatedAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // última atualização do índice no dashboard.
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE dfds ADD COLUMN updatedAt TEXT');
          await db.execute(
            'UPDATE dfds SET updatedAt = dataCriacao WHERE updatedAt IS NULL',
          );
        }
      },
    );
  }

  // CREATE
  Future<int> insertDfd(Dfd dfd) async {
    try {
      final db = await database;
      final data = dfd.toMap()
        ..['updatedAt'] = DateTime.now().toIso8601String();
      return db.insert('dfds', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Erro ao inserir DFD: $e');
      rethrow;
    }
  }

  // READ ALL
  Future<List<Dfd>> getAllDfds() async {
    try {
      final db = await database;
      final maps = await db.query('dfds', orderBy: 'id DESC');
      return maps.map((m) => Dfd.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Erro ao listar DFDs: $e');
      rethrow;
    }
  }

  // READ com busca por código ou justificativa
  Future<List<Dfd>> searchDfds(String query) async {
    try {
      final db = await database;
      final escaped = query
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      final maps = await db.query(
        'dfds',
        where: "codigo LIKE ? ESCAPE '\\' OR justificativa LIKE ? ESCAPE '\\'",
        whereArgs: ['%$escaped%', '%$escaped%'],
        orderBy: 'id DESC',
      );
      return maps.map((m) => Dfd.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar DFDs: $e');
      rethrow;
    }
  }

  // UPDATE
  Future<void> updateDfd(Dfd dfd) async {
    try {
      final db = await database;
      final data = dfd.toMap()
        ..['updatedAt'] = DateTime.now().toIso8601String();
      await db.update(
        'dfds',
        data,
        where: 'id = ?',
        whereArgs: [dfd.id],
      );
    } catch (e) {
      debugPrint('Erro ao atualizar DFD: $e');
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteDfd(int id) async {
    try {
      final db = await database;
      await db.delete('dfds', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Erro ao deletar DFD: $e');
      rethrow;
    }
  }

  Future<DfdStats> getStats() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final anoMes = '${now.year.toString().padLeft(4, '0')}'
          '-${now.month.toString().padLeft(2, '0')}';

      final totalResult =
      await db.rawQuery('SELECT COUNT(*) AS total FROM dfds');
      final total = Sqflite.firstIntValue(totalResult) ?? 0;

      final mesResult = await db.rawQuery(
        "SELECT COUNT(*) AS total FROM dfds "
            "WHERE strftime('%Y-%m', dataCriacao) = ?",
        [anoMes],
      );
      final cadastradasNoMes = Sqflite.firstIntValue(mesResult) ?? 0;

      final ultimaResult =
      await db.rawQuery('SELECT MAX(updatedAt) AS ultima FROM dfds');
      final ultimaRaw = ultimaResult.first['ultima'] as String?;
      final ultimaAtualizacao =
      ultimaRaw != null ? DateTime.tryParse(ultimaRaw) : null;

      return DfdStats(
        total: total,
        cadastradasNoMes: cadastradasNoMes,
        ultimaAtualizacao: ultimaAtualizacao,
      );
    } catch (e) {
      debugPrint('Erro ao obter estatísticas: $e');
      rethrow;
    }
  }
}