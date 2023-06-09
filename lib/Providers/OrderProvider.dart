import 'package:flutter/material.dart';
import '../Helper/Db.dart';
import '../Helper/OrderDatabase.dart';
import '../Models/Order.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../Models/Sale.dart';

class OrderProvider with ChangeNotifier {
  late List<Order> _orders = [];
  late List<Sale> _orderProducts = [];
  late List<Map<String, dynamic>> getMostHightestProducts = [];
  List<Order> get orders {
    return [..._orders];
  }

  List<Sale> get orderProducts {
    return [..._orderProducts];
  }

  Future<bool> addOrders(List<Sale> sales, String name, String phone,
      String address, int fees, int totalSales) async {
    final List<Map<String, dynamic>> orderProducts = [];

    final Map<String, dynamic> order = {
      'total_price': totalSales + fees,
      'name': name,
      'phone': phone,
      'address': address,
      'delivery_fees': fees,
      'created_at': DateTime.now().toIso8601String(),
    };

    //return order id for relationship
    final order_id = await OrderDatabase.insertOrders('orders', order);

    for (var element in sales) {
      orderProducts.add({
        'order_id': order_id,
        'product_id': element.id,
        'quantity': element.quantity,
        'product_price': element.price,
        'total': element.price * element.quantity
      });
    }

    await OrderDatabase.insertOrderProductss(
        'order_products', orderProducts, fees);

    return true;
  }

  getTotalOrder() {
    return _orders.length;
  }

  getTotalMoney() {
    late int money = 0;
    _orders.map((e) => money += e.total_price).toList();
    return money;
  }

  Future<void> getMostHightestProduct() async {
    getMostHightestProducts = [];
    final data = await Db.getMostHighestProducts();
    if (data.isEmpty) {
      return;
    }
    data.map((e) => getMostHightestProducts.add(e)).toList();
  }

  Future<void> getOrdersDatas() async {
    final data = await OrderDatabase.getOrdersData();
    _orders = [];
    if (data.isNotEmpty) {
      data.map(
        (e) {
          _orders.add(
            Order(
              e['id'],
              e['total_price'],
              e['name'],
              e['phone'],
              e['address'],
              e['delivery_fees'],
              e['created_at'],
            ),
          );
        },
      ).toList();
    }
    notifyListeners();
  }

  Future<void> fetchorderProducts(int order_id) async {
    final data = await OrderDatabase.getOrderProductDatas(order_id);
    print(data);
    _orderProducts = [];
    if (data.isNotEmpty) {
      data
          .map(
            (e) => _orderProducts.add(
              Sale(
                e['id'],
                e['barcode'],
                e['product_name'],
                e['category_name'],
                e['product_price'],
                quantity: e['quantity'],
              ),
            ),
          )
          .toList();
    }

    notifyListeners();
  }
}
