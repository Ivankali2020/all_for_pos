import 'package:flutter/material.dart';
import '../Models/Product.dart';
import '../Models/TransitionPage.dart';
import '../Screen/EditProduct.dart';
import 'package:path/path.dart';
import '../Providers/ProductProvider.dart';
import 'package:provider/provider.dart';

class ProductWidgets extends StatelessWidget {
  const ProductWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    void deleteProduct(int id, Product product) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(product.name),
          content:
              const Text('You can not be restore this items! Are you Sure?'),
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  Provider.of<ProductProvider>(context, listen: false)
                      .deleteProduct(id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'))
          ],
        ),
      );
    }

    return Consumer<ProductProvider>(
      // child: const Center(child: Text('No Place Found')),
      builder: (context, value, child) => value.items.length > 0
          ? ListView.builder(
              itemCount: value.items.length,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(value.items[i].name),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRICE : ${value.items[i].price} CAT : ${value.items[i].category}' ),
                      Text('BARCODE : ${value.items[i].barcode}')
                    ],
                  ),
                  trailing: Container(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(fadePageRoute('routeName', EditProduct(
                                      value.items[i],
                                      key: key,
                                    )));
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () =>
                              deleteProduct(value.items[i].id, value.items[i]),
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(
              child: Text('No Products Found'),
            ),
    );
  }
}
