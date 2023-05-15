import 'dart:math';

import 'package:flutter/material.dart';
import 'package:greate_places/Models/Sale.dart';
import '../Helper/Db.dart';
import '../Screen/SaleProduct.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../Models/Product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  List<Sale> _sales = [];

  List<Product> get items {
    return [..._items];
  }

  List<Sale> get sales {
    return [..._sales];
  }

  void addProduct(String name, int price, Barcode? barcode) {
    final data = Db.insert('new_products',
        {'barcode': barcode?.code, 'name': name, 'price': price});

    _items.add(Product(Random().nextInt(999999), barcode?.code, name, price));

    notifyListeners();
  }

  Future<void> fetchDatas() async {
    final data = await Db.gethDatas('new_products');

    if (data.length > 0) {
      _items = data
          .map((e) =>
              Product(e['id'], e['barcode'], e['name'].toString(), e['price']))
          .toList();
    }
  }

  Future<void> searchByBarcode(String? barcode) async {
    if (barcode != null) {
      final data =
          _items.where((element) => element.barcode == barcode).toList();

      if (_sales.isNotEmpty) {
        var check =
            _sales.where((element) => element.barcode == barcode).toList();
        if (check.isNotEmpty) {
          //only update quantity
          check[0].quantity++;
        } else {
          _sales.add(Sale(1, data[0].barcode, data[0].name, data[0].price));
        }
      } else {
        _sales.add(Sale(1, data[0].barcode, data[0].name, data[0].price));
      }
      totalSales();
      notifyListeners();
    }
  }

  late int total = 0;

  void totalSales() {
    total = _sales
        .map((e) => e.price * e.quantity)
        .reduce((value, element) => value + element);
  }

  Future<void> deleteTabale() async {
    await Db.deleteTabel();
    notifyListeners();
  }
}
