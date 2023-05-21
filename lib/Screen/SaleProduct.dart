import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greate_places/Models/Sale.dart';
import 'package:greate_places/Models/TransitionPage.dart';
import 'package:greate_places/Providers/OrderProvider.dart';
import 'package:greate_places/Providers/ProductProvider.dart';
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

  @override
  Widget build(BuildContext context) {
    // final sales = Provider.of<ProductProvider>(context).sales;
    return Scaffold(
      appBar: AppBar(title: const Text('Sale Product')),
      body: ListView(
        children: [
          isScan
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Expanded(
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
                        ElevatedButton.icon(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Resume'),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isScan = true;
                        });
                      },
                      icon: const Icon(Icons.scanner_outlined),
                      label: const Text('Scan Now')),
                ),
          SizedBox(
            height: 500,
            child: Consumer<ProductProvider>(
              builder: (ctx, value, child) => value.sales.length > 0
                  ? SaleProducts(value.sales)
                  : const Center(
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


      await Provider.of<OrderProvider>(context, listen: false).addOrders(
        widget.sales.toList(),
        name_controller.text,
        phone_controller.text,
        address_controller.text,
        int.parse(delivery_fees_controller.text),
        Provider.of<ProductProvider>(context, listen: false).total,
      ).then((value){

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
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.sales.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(
                widget.sales[i].name,
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
