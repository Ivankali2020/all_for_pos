import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos/Models/Product.dart';
import '../Models/Sale.dart';
import '../Models/TransitionPage.dart';
import '../Providers/OrderProvider.dart';
import '../Providers/ProductProvider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SaleProduct extends StatefulWidget {
  SaleProduct({super.key});

  @override
  State<SaleProduct> createState() => _SaleProductState();
}

class _SaleProductState extends State<SaleProduct> {
  GlobalKey key = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  late Barcode result;
  bool isScan = false;
  Future<void> scanBarCode(QRViewController _controller) async {
    _controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller = _controller;
        controller?.pauseCamera();
        // isScan = false;
      });
      Provider.of<ProductProvider>(context, listen: false)
          .searchByBarcode(result.code)
          .then((value) {
        if (!value) {
          Alert('Barcode is not find our database',
              Color.fromARGB(255, 255, 255, 255), context);
        }
      });
    });
  }

  Future selectProducts(BuildContext context, List<Product> products) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return Consumer<ProductProvider>(
          builder: (context, value, child) {
            return value.items.isEmpty
                ? const Center(
                    child: Text('no products'),
                  )
                : Container(
                    height: 300,
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount: value.items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 5,
                        crossAxisCount: 3,
                        childAspectRatio: 1.3,
                      ),
                      itemBuilder: (context, i) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Provider.of<ProductProvider>(context,
                                      listen: false)
                                  .searchByBarcode(value.items[i].barcode)
                                  .then((value) {
                                if (!value) {
                                  Alert(
                                    'Barcode is not find our database',
                                    Color.fromARGB(255, 255, 255, 255),
                                    context,
                                  );
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 3,
                                  top: 3,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        color: value.items[i].isChoose
                                            ? Colors.greenAccent
                                            : Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(
                                      Icons.check,
                                      color: value.items[i].isChoose
                                          ? Colors.white
                                          : Colors.black,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FittedBox(
                                          alignment: Alignment.center,
                                          child: Text(
                                            value.items[i].name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        FittedBox(
                                          child: Text(
                                            'cat : ${value.items[i].category}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        FittedBox(
                                          child: Text(
                                            'price : ${value.items[i].price}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context, listen: false).items;
    // final sales = Provider.of<ProductProvider>(context).sales;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Sale Product')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isScan
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(border: Border.all()),
                          child: QRView(key: key, onQRViewCreated: scanBarCode),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await controller?.resumeCamera();
                              },
                              icon: const Icon(Icons.restore),
                              label: const Text('Resume'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                return selectProducts(context, products);
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Select Products'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(border: Border.all()),
                      child: const Text('Scanner'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isScan = true;
                            });
                          },
                          icon: const Icon(Icons.scanner_outlined),
                          label: const Text('Scan Now'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            return selectProducts(context, products);
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Select Products'),
                        ),
                      ],
                    )
                  ],
                ),
          Consumer<ProductProvider>(
            builder: (ctx, value, child) => value.sales.length > 0
                ? SaleProducts(value.sales)
                : const Expanded(
                    child: Center(
                      child: Text('No Sales'),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

class SaleProducts extends StatefulWidget {
  late List<Sale> sales = [];
  SaleProducts(this.sales);
  late bool isLoading = false;

  @override
  State<SaleProducts> createState() => _SaleProductsState();
}

class _SaleProductsState extends State<SaleProducts> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  TextEditingController delivery_fees_controller = TextEditingController();
  TextEditingController name_controller = TextEditingController();
  TextEditingController phone_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    delivery_fees_controller.dispose();
    name_controller.dispose();
    phone_controller.dispose();
    address_controller.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (widget.sales.isEmpty || delivery_fees_controller.text == null) {
      Alert('Barcode is not find our database',
          Color.fromARGB(255, 255, 255, 255), context);
    }

    if (key.currentState!.validate()) {
      // Form is valid, perform the submission
      key.currentState!.save();
      setState(() {
        widget.isLoading = true;
      });

      Provider.of<ProductProvider>(context, listen: false).cleanSales();

      await Provider.of<OrderProvider>(context, listen: false)
          .addOrders(
        widget.sales.toList(),
        name_controller.text,
        phone_controller.text,
        address_controller.text,
        int.parse(delivery_fees_controller.text),
        Provider.of<ProductProvider>(context, listen: false).total,
      )
          .then((value) {
        Navigator.of(context).pushReplacementNamed('print');
      });
    }
  }

  Future _print(context) {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Form(
            key: key,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  const Center(
                    child: Text(
                      'User Infomation',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'User Name',
                      border: OutlineInputBorder(gapPadding: 1),
                    ),
                    controller: name_controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'User Phone',
                      border: OutlineInputBorder(gapPadding: 1),
                    ),
                    keyboardType: TextInputType.number,
                    controller: phone_controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'User Address',
                      border: OutlineInputBorder(gapPadding: 1),
                    ),
                    controller: address_controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      null;
                    },
                    onChanged: (v) => v,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Delivery Fees',
                      border: OutlineInputBorder(gapPadding: 1),
                    ),
                    keyboardType: TextInputType.number,
                    controller: delivery_fees_controller,
                    validator: (value) {
                      if (value == null ||
                          int.tryParse(value) == null ||
                          value.isEmpty) {
                        return 'Required';
                      }
                      null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Print Now'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: widget.sales.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(
                widget.sales[i].product_name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Text(
                  '${widget.sales[i].price.toString()} Ks x ${widget.sales[i].quantity} qty = ${widget.sales[i].price * widget.sales[i].quantity} Ks'),
              trailing: Container(
                width: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).accentColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () => Provider.of<ProductProvider>(context,
                                listen: false)
                            .quantityUpdate(widget.sales[i].barcode, false)
                            .then((value) => value
                                ? Alert(
                                    'Quality Remove',
                                    Color.fromARGB(255, 253, 253, 253),
                                    context,
                                  )
                                : Alert('ERROR', Colors.redAccent, context)),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.black,
                          size: 16,
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white),
                      child: Text(
                        widget.sales[i].quantity.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    InkWell(
                        onTap: () => Provider.of<ProductProvider>(context,
                                listen: false)
                            .quantityUpdate(widget.sales[i].barcode, true)
                            .then((value) => value
                                ? Alert(
                                    'Quality Added',
                                    Color.fromARGB(255, 253, 253, 253),
                                    context,
                                  )
                                : Alert('ERROR', Colors.redAccent, context)),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 16,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Consumer<ProductProvider>(
                builder: (context, value, child) => Text(
                  'TOTAL : ${value.total}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              widget.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ChangeNotifierProvider.value(
                      value: OrderProvider(),
                      builder: (context, child) => TextButton.icon(
                        onPressed: () => _print(context),
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                      ),
                    ),
            ],
          ),
        )
      ],
    );
  }
}

void Alert(String message, Color color, BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          message,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          icon: const Icon(Icons.close),
        )
      ],
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: color,
  ));
}
