import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class OrderDatabase {
  static Future<Database> createOrderProductsDatabase() async {
    final db = await getDatabasePath();
    await db.execute(
        'CREATE TABLE order_products (id INTEGER PRIMARY KEY AUTOINCREMENT,order_id INTEGER,product_id INTEGER,product_price INTEGER,quantity INTEGER,total INTEGER)');

    return db;
  }

  static Future<Database> createOrdersDatabases() async {
    final db = await getDatabasePath();
    await db.execute(
        'CREATE TABLE orders (id INTEGER PRIMARY KEY AUTOINCREMENT,total_price INTEGER,name TEXT,phone TEXT,address TEXT,delivery_fees INTEGER,created_at DATETIME)');
    return db;
  }

  static Future<bool> checkTableExists(String tableName) async {
    late bool check = false;
    final db = await getDatabasePath();
    final tables = await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    tables.forEach((table) {
      if (table['name'] == tableName) {
        check = true;
      }
    });

    return check;
  }

  static Future<Database> getDatabasePath() async {
    final dbpath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbpath, 'POS.db'));
    return db;
  }

  static Future<int> insertOrders(
      String table, Map<String, dynamic> order) async {
    //for orders table
    final check = await OrderDatabase.checkTableExists('orders');

    if (check) {
        final db = await getDatabasePath();
        final id = await db.insert(table, order,
            conflictAlgorithm: ConflictAlgorithm.replace);
        return id;
      }
        final db = await OrderDatabase.createOrdersDatabases();
        final id = await db.insert(table, order,
            conflictAlgorithm: ConflictAlgorithm.replace);
        return id;
  }

  static Future<void> insertOrderProductss(
      String table, List<Map<String, dynamic>> sales, int fees) async {
    OrderDatabase.checkTableExists('order_products').then((value) async {
      if (value) {
        final db = await getDatabasePath();
        for (var order in sales) {
          await db.insert(table, order,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } else {
        final db = await OrderDatabase.createOrderProductsDatabase();
        for (var order in sales) {
          await db.insert(table, order,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getOrdersData() async {
    final db = await OrderDatabase.getDatabasePath();
    return db.rawQuery('SELECT * FROM orders ORDER BY id DESC');
  }

  static Future<List<Map<String, dynamic>>> getOrderProductDatas(
      int order_id) async {
    final db = await OrderDatabase.getDatabasePath();
    return db.rawQuery('SELECT * FROM order_products LEFT JOIN new_products ON order_products.product_id=new_products.id WHERE order_id=$order_id ');
  }
}
