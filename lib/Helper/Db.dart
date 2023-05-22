import '../Models/Product.dart';
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

  static Future<void> delete(String table, int id) async {
    final sqlDb = await Db.createDatabase();
    sqlDb.delete(table, where: 'id=?', whereArgs: [id]);
  }

  static Future<void> updateProduct(
      int id, Map<String, dynamic> product, String table) async {
    final sqlDb = await Db.createDatabase();
    sqlDb.update(table, product, where: 'id=?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic?>>> gethDatas(String table) async {
    final sqlDb = await Db.createDatabase();
    return sqlDb.query(table);
  }

  static Future<List<Map<String, dynamic>>> getMostHighestProducts() async {
    final sqlDb = await Db.createDatabase();
    return sqlDb.rawQuery(
        "SELECT new_products.id,new_products.barcode,new_products.name,SUM(order_products.total) as total_sales FROM new_products JOIN order_products ON new_products.id = order_products.product_id GROUP BY new_products.id,new_products.name ORDER BY total_sales DESC");
  }
}
