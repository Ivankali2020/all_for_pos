import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class Db {
  static Future<Database> createDatabase() async {
    final dbpath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbpath, 'POS.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE new_products (id INTEGER PRIMARY KEY AUTOINCREMENT,barcode TEXT, name TEXT,price INTEGER)');
    }, version: 1);
  }

  static Future<void> createNewDatabase() async {
    final sqlDb = await Db.createDatabase();
    await sqlDb.execute(
        'CREATE TABLE new_products (id INTEGER PRIMARY KEY AUTOINCREMENT,barcode TEXT, name TEXT,price INTEGER)');
  }

  static Future<void> deleteTabel() async {
    final sqlDb = await Db.createDatabase();
    await sqlDb.execute('DROP TABLE IF EXISTS new_products');
    Db.createNewDatabase();
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final sqlDb = await Db.createDatabase();
    sqlDb.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic?>>> gethDatas(String table) async {
    final sqlDb = await Db.createDatabase();
    return sqlDb.query(table);
  }
}
