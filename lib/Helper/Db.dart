import 'dart:io';

import 'package:pos/Helper/OrderDatabase.dart';

import '../Models/Product.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class Db {
  static Future<void> createAllDatabases() async {
    final dbpath = await sql.getDatabasesPath();

    if (File(path.join(dbpath, 'POS.db')).existsSync()) {
      print('shie');
      return;
    }
    final db = await sql.openDatabase(path.join(dbpath, 'POS.db'), version: 1);

    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS new_products');
      await txn.execute(//for product
          'CREATE TABLE new_products (id INTEGER PRIMARY KEY AUTOINCREMENT,barcode TEXT, name TEXT, category_id INTEGER,price INTEGER)');

      await txn.execute('DROP TABLE IF EXISTS categories');
      await txn.execute(
        //for category
        'CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
      );

      await txn.execute('DROP TABLE IF EXISTS order_products');
      await txn.execute(//for orderproducts
          'CREATE TABLE order_products (id INTEGER PRIMARY KEY AUTOINCREMENT,order_id INTEGER,product_id INTEGER,product_price INTEGER,quantity INTEGER,total INTEGER)');

      await txn.execute('DROP TABLE IF EXISTS orders');
      await txn.execute(//for orders
          'CREATE TABLE orders (id INTEGER PRIMARY KEY AUTOINCREMENT,total_price INTEGER,name TEXT,phone TEXT,address TEXT,delivery_fees INTEGER,created_at DATETIME)');
    });

    await db.close();

    print('success');
  }

  static Future<Database> getDatabasePath() async {
    final dbpath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbpath, 'POS.db'));
    return db;
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final sqlDb = await Db.getDatabasePath();
    sqlDb.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> delete(String table, int id) async {
    final sqlDb = await Db.getDatabasePath();
    sqlDb.delete(table, where: 'id=?', whereArgs: [id]);
  }

  static Future<void> updateProduct(
      int id, Map<String, dynamic> product, String table) async {
    final sqlDb = await Db.getDatabasePath();
    sqlDb.update(table, product, where: 'id=?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic?>>> gethDatas(String table) async {
    final sqlDb = await Db.getDatabasePath();
    return sqlDb.rawQuery("SELECT new_products.*,categories.name AS category_name FROM  new_products LEFT JOIN categories ON new_products.category_id = categories.id ");
  }

  static Future<List<Map<String, dynamic>>> getMostHighestProducts() async {
    final sqlDb = await Db.getDatabasePath();

    final check = await OrderDatabase.checkTableExists('orders');

    if (check) {
      print(check);
      return sqlDb.rawQuery(
          "SELECT new_products.id,new_products.barcode,new_products.name,SUM(order_products.total) as total_sales FROM new_products JOIN order_products ON new_products.id = order_products.product_id GROUP BY new_products.id,new_products.name ORDER BY total_sales DESC");
    } else {
      final List<Map<String, dynamic>> data = [];
      return data;
    }
  }
}
