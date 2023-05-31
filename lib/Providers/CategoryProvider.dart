import 'package:flutter/foundation.dart';
import 'package:pos/Helper/CategoryDatabase.dart';
import 'package:pos/Helper/Db.dart';
import '../Models/Category.dart' as category;

class CategoryProvider with ChangeNotifier {
  late List<category.Category> _categories = [];

  List<category.Category> get categories {
    return [..._categories];
  }

  //for choose category_id //

  late category.Category _selectedCategoryId;


  category.Category get selectedCategoryId  => _selectedCategoryId;

  set selectedCategoryId(category.Category category) {
    _selectedCategoryId = category;
    notifyListeners();
  }

  Future<void> createCategory(String name) async {
    final id = await CategoryDatabase.insertData({'name': name});
    getCategories();
    notifyListeners();
  }

  Future<void> getCategories() async {
    _categories = [];
    final data = await CategoryDatabase.fetchCategories();
    if (data.isNotEmpty) {
      data.map((e) => _categories.add(category.Category.fromJson(e))).toList();
    }
    notifyListeners();
    print(data);
  }

  Future<void> updateCategory(int id, String name) async {
    final success = await CategoryDatabase.updateCategory(id, {'name': name});
    if (success) {
      _categories.map((element) {
        if (element.id == id) {
          element.name = name;
        }
      }).toList();
    }
    notifyListeners();
  }

  Future<void> deleteCategory(int id, category.Category category) async {
    final success = await CategoryDatabase.deleteCategory(id);
    if (success) {
      _categories.remove(category);
    }
    notifyListeners();
  }
}
