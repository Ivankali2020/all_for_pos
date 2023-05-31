import 'package:path/path.dart' as path;
import 'package:pos/Helper/Db.dart';
import 'package:pos/Helper/OrderDatabase.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class CategoryDatabase {
  static Future<bool> insertData(Map<String, dynamic> data) async {
    final sql = await Db.getDatabasePath();
    final id = await sql.insert('categories', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final sql = await Db.getDatabasePath();
    final data = await sql.query('categories');
    return data;
  }

  static Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    final sql = await Db.getDatabasePath();
    await sql.update('categories', data, where: "id = ?", whereArgs: [id]);
    return true;
  }

  static Future<bool> deleteCategory(int id) async {
    final sql = await Db.getDatabasePath();
    await sql.delete('categories', where: 'id=?', whereArgs: [id]);
    return true;
  }
}
