import 'package:flutter/material.dart';
import 'package:greate_places/Models/Order.dart';
import 'package:greate_places/Providers/OrderProvider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final order = data['order_data'];
    print(order);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
      ),
      body: FutureBuilder(
          future: Provider.of<OrderProvider>(context, listen: false)
              .fetchorderProducts(order.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final orderProducts =
                  Provider.of<OrderProvider>(context).orderProducts;
              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "User Info",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                "Date : ${DateFormat.yMEd().format(DateTime.parse(order.created_at))}",
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Name'),
                              Text(
                                " ${order.name} ",
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Phone'),
                              Text(
                                " ${order.phone} ",
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Address'),
                              Text(
                                " ${order.address} ",
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  orderProducts.isEmpty
                      ? const Center(
                          child: Text('No Products Found'),
                        )
                      : Expanded(
                          child: ListView.builder(
                              itemCount: orderProducts.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black26, width: 0.5),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    title: Text(orderProducts[i].name),
                                    subtitle: Text((orderProducts[i].price *
                                            orderProducts[i].quantity)
                                        .toString()),
                                    trailing: Column(
                                      children: [
                                        Text(
                                            '${orderProducts[i].price.toString()} Ks'),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                            "x ${orderProducts[i].quantity.toString()} qty"),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              "Order Summary",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text(
                                " ${order.total_price - order.fees} Ks",
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery'),
                              Text(
                                " ${order.fees} Ks",
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                " ${order.total_price} Ks",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
