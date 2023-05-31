import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../Models/TransitionPage.dart';
import '../Providers/OrderProvider.dart';
import '../Screen/OrderDetailScreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future? isInit;

  Future<void> fetchOrders() async {
    Provider.of<OrderProvider>(context, listen: false).getOrdersDatas();
  }

  @override
  void initState() {
    isInit = fetchOrders();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: FutureBuilder(
        future: isInit,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final orders = Provider.of<OrderProvider>(context).orders;
            return Center(
              child: orders.isEmpty
                  ? const Center(
                      child: Text('No Orders Found!'),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, i) => Container(
                            child: Container(
                              margin: const EdgeInsets.all(15),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                       const Icon(Icons.shopping_bag_outlined),
                                       Text(
                                        'Order No : # ${orders[i].id.toString()}',
                                        style:const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "${orders[i].total_price.toString()} Ks",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(fadePageRoute('detail', OrderDetailScreen(),arguments: {
                                                'order_data': orders[i]
                                              }) );
                                        },
                                        child: Container(
                                          width: 80,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.black45,
                                                  width: 0.5)),
                                          child: const Text('Detail'),
                                        ),
                                      ),
                                      Text(DateFormat.yMEd().format(
                                          DateTime.parse(
                                              orders[i].created_at))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
            );
          }
        },
      ),
    );
  }
}
