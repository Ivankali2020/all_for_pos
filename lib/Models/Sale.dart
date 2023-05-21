class Sale {
  final int id;
  final String? barcode;
  final String name;
  final int price;
  late int quantity = 1;

  Sale(this.id, this.barcode, this.name, this.price,{required this.quantity});

  void toggelDone()
  {
     quantity++;
  }

  void decreaseDown() {
    quantity == 0 ? 0 : quantity--;
  }
}
