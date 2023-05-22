import 'dart:math';

import 'package:flutter/material.dart';
import 'package:greate_places/Models/Sale.dart';
import '../Helper/Db.dart';
import '../Screen/SaleProduct.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../Models/Product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items {
    return [..._items];
  }

  List<Sale> _sales = [];
  List<Sale> get sales {
    return [..._sales];
  }

  Future<bool> searchBarCode(String barcode) async {
    final check = _items.where((element) => element.barcode == barcode);
    if (check.isNotEmpty) {
      print('shi tal');
      return false;
    } else {
      print('ma shi tal');
      return true;
    }
  }

  Future<bool> addProduct(String name, int price, Barcode? barcode) async {
    final check = _items.where((element) => element.barcode == barcode);

    if (check.isNotEmpty) {
      return false;
    } else {
      final data = await Db.insert('new_products',
          {'barcode': barcode?.code, 'name': name, 'price': price});

      _items.add(Product(Random().nextInt(999999), barcode?.code, name, price));

      notifyListeners();
      return true;
    }
  }

  Future<bool> editProduct(
      String name, int price, String? barcode, int id) async {
    Map<String, dynamic> product = {
      'name': name,
      'price': price,
      'barcode': barcode
    };
    Db.updateProduct(id, product, 'new_products');
    notifyListeners();
    return true;
  }

  Future<void> fetchDatas() async {
    final data = await Db.gethDatas('new_products');

    if (data.length > 0) {
      _items = data
          .map(
            (e) => Product(
              e['id'],
              e['barcode'],
              e['name'].toString(),
              e['price'],
            ),
          )
          .toList();
    }
  }

  Future<void> deleteProduct(int id) async {
    Db.delete('new_products', id);
    notifyListeners();
  }

  Future<bool> searchByBarcode(String? barcode) async {
    if (barcode != null) {
      final data =
          _items.where((element) => element.barcode == barcode).toList();

      if (data.isEmpty) {
        return false;
      }

      if (_sales.isNotEmpty) {
        var check =
            _sales.where((element) => element.barcode == barcode).toList();
        if (check.isNotEmpty) {
          //only update quantity
          // check[0].quantity++;
          check[0].toggelDone();
        } else {
          _sales.add(
            Sale(
              data[0].id,
              data[0].barcode,
              data[0].name,
              data[0].price,
              quantity: 1,
            ),
          );
        }
      } else {
        _sales.add(
          Sale(
            data[0].id,
            data[0].barcode,
            data[0].name,
            data[0].price,
            quantity: 1,
          ),
        );
      }
      totalSales();
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> quantityUpdate(String? barcode, bool isAdd) async {
    var check = _sales.where((element) => element.barcode == barcode).toList();
    if (check.isNotEmpty) {
      //only update quantity
      if (isAdd) {
        check[0].toggelDone();
        notifyListeners();
      } else {
        check[0].decreaseDown();
        if (check[0].quantity == 0) {
          _sales.removeWhere((element) => element.barcode == barcode);
          notifyListeners();
        }
      }
      totalSales();
      notifyListeners();
      return true;
    } else {
      return false;
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

  Future<void> cleanSales() async {
    _sales = [];
  }
}
