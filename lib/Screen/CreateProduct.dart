import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../Providers/ProductProvider.dart';
import 'package:provider/provider.dart';

class CreateProduct extends StatefulWidget {
  CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late String productName;
  late int productPrice;
  Barcode? result;

  bool isScanned = false;

  late QRViewController? controller;

  Future<void> scanBarCode(QRViewController controller) async {
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        isScanned = !isScanned;
        controller.pauseCamera();
        return;
      });
    });
  }

  void _createProduct(ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              isScanned
                  ? Text('${result != null ? result?.code : ""}')
                  : Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(width: .5, color: Colors.black)),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: scanBarCode,
                        overlay: QrScannerOverlayShape(
                            borderColor: Colors.red,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: double.infinity),
                      ),
                    )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OM POS'),
        actions: [
          IconButton(
              onPressed: () => _createProduct(context),
              icon: Icon(Icons.barcode_reader))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text('Barcode No : ${result != null ? result?.code : "Scan Now"}'),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(gapPadding: 1),
              ),
              onChanged: (value) {
                productName = value;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Product Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                productPrice = int.tryParse(value) ?? 0;
              },
            ),
            TextButton(
              onPressed: ()  {
                if (productName == null || productPrice == null) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      'Need Some Field',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.white,
                  ));
                } else {
                   Provider.of<ProductProvider>(context, listen: false)
                      .addProduct(productName, productPrice, result);

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      'Success',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.white,
                  ));

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
