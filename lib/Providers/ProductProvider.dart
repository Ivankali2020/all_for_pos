import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pos/Models/Category.dart';
import '../Models/Sale.dart';
import '../Helper/Db.dart';
import '../Screen/SaleProduct.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../Models/Product.dart';

class ProductProvider with ChangeNotifier {
  late bool isCreateDatabases = false;
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
      return false;
    } else {
      print('ma shi tal');
      return true;
    }
  }

  Future<bool> addProduct(
      String name, int price, Barcode? barcode, Category category) async {
    final check = _items.where((element) => element.barcode == barcode);

    if (check.isNotEmpty) {
      return false;
    } else {
      final data = await Db.insert(
        'new_products',
        {
          'barcode': barcode?.code,
          'name': name,
          'price': price,
          'category_id': category.id,
        },
      );

      _items.add(
        Product(
          Random().nextInt(999999),
          barcode?.code,
          name,
          price,
          category.id,
          category.name,
        ),
      );

      notifyListeners();
      return true;
    }
  }

  Future<bool> editProduct(String name, int price, String? barcode, int id,
      Category category) async {
    Map<String, dynamic> product = {
      'name': name,
      'price': price,
      'barcode': barcode,
      'category_id': category.id,
    };
    Db.updateProduct(id, product, 'new_products');
    notifyListeners();
    return true;
  }

  Future<void> fetchDatas() async {
    if (!isCreateDatabases) {
      print('CREAATE');
      await Db.createAllDatabases();
      isCreateDatabases = true;
    }
    final data = await Db.gethDatas('new_products');
    if (data.length > 0) {
      _items = data
          .map(
            (e) => Product(e['id'], e['barcode'], e['name'].toString(),
                e['price'], e['category_id'], e['category_name']),
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
      final p = _items.map((element) => element.barcode == barcode).toList();
      print(p);
      print(barcode);
      if (data.isEmpty) {
        return false;
      }

      if (_sales.isNotEmpty) {
        var check =
            _sales.where((element) => element.barcode == barcode).toList();
        if (check.isNotEmpty) {
          //update quantity
          check[0].toggelDone();
        } else {
          _sales.add(
            Sale(
              data[0].id,
              data[0].barcode,
              data[0].name,
              data[0].category,
              data[0].price,
              quantity: 1,
            ),
          );
          _items
              .where((element) => element.barcode == barcode)
              .toList()[0]
              .toogleChoose();
          notifyListeners();
        }
      } else {
        _sales.add(
          Sale(
            data[0].id,
            data[0].barcode,
            data[0].name,
            data[0].category,
            data[0].price,
            quantity: 1,
          ),
        );
        _items
            .where((element) => element.barcode == barcode)
            .toList()[0]
            .toogleChoose();
        notifyListeners();
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

  // Future<void> deleteTabale() async {
  //   await Db.deleteTabel();
  //   notifyListeners();
  // }

  Future<void> cleanSales() async {
    _sales = [];
  }
}
