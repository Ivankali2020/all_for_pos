class Product {
  final int id;
  final String? barcode;
  final String name;
  final int price;
  final int category_id;
  final String category;
  late bool isChoose = false;

  void toogleChoose() {
    isChoose = !isChoose;
  }
  Product(this.id, this.barcode, this.name, this.price, this.category_id, this.category);
}
