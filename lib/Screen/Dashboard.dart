import 'package:flutter/material.dart';
import 'package:greate_places/Providers/OrderProvider.dart';
import 'package:greate_places/Providers/ProductProvider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Dasboard extends StatelessWidget {
  const Dasboard({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<OrderProvider>(context, listen: false).getOrdersDatas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text(
                      'Total Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Consumer<ProductProvider>(builder: (context, value, child) {
                      return Text(
                        "${value.items.length.toString()} pcs",
                        style: const TextStyle(fontSize: 17),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Total Revenue',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Consumer<OrderProvider>(
                            builder: (context, value, child) {
                          return Text(
                            NumberFormat.currency(symbol: '')
                                .format(value.getTotalMoney()),
                            style: const TextStyle(fontSize: 17),
                          );
                        })
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Total Orders',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Consumer<OrderProvider>(
                            builder: (context, value, child) {
                          return Text(
                            value.getTotalOrder().toString(),
                            style: const TextStyle(fontSize: 17),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20,),
             const Center(child:  Text('Highest Sales ',style:  TextStyle(fontSize: 17,color: Colors.black26),)),
            const SizedBox(height: 15,),
            FutureBuilder(
                future: Provider.of<OrderProvider>(context, listen: false)
                    .getMostHightestProduct(),
                builder: (context, snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapShot.connectionState == ConnectionState.done) {
                      final orderProducts =
                          Provider.of<OrderProvider>(context, listen: false)
                              .getMostHightestProducts;
                      return orderProducts.isEmpty
                          ? const Center(
                              child: Text('No Products Found'),
                            )
                          : Expanded(
                              child: ListView.builder(
                                  itemCount: orderProducts.length,
                                  itemBuilder: (context, i) {
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black26,
                                              width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: ListTile(
                                        title: Text(orderProducts[i]['name']),
                                        subtitle:
                                            Text(orderProducts[i]['barcode']),
                                        trailing: Column(
                                          children: [
                                            const Text('Total'),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(NumberFormat.currency(symbol: '').format(orderProducts[i]['total_sales'])+' ks'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            );
                    }

                    return Center(
                      child: Text('ERROR'),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}
