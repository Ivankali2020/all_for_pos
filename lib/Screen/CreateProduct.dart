import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
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
  String? productName;
  int? productPrice;
  Barcode? result;

  bool isScanned = false;

  late QRViewController? controller;

  Future<void> scanBarCode(QRViewController controller) async {
    controller.scannedDataStream.listen((scanData) {
      Provider.of<ProductProvider>(context, listen: false)
          .searchBarCode(scanData.code!)
          .then((value) {
        if (!value) {
          Alert(context, 'Exists barcode');
          controller.pauseCamera();
        } else {
          setState(() {
            result = scanData;
            isScanned = !isScanned;
            controller.pauseCamera();
            return;
          });
        }
        Navigator.of(context).pop();

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
                  ? Container(
                      alignment: Alignment.center,
                      height: 100,
                      width: 300,
                      child: result != null
                          ? SfBarcodeGenerator(
                              value: result!.code,
                              showValue: true,
                              textSpacing: 10,
                            )
                          : const Text('NUL BAR CODE'),
                    )
                  : Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(width: .5, color: Colors.black),
                      ),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: scanBarCode,
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
              isScanned
                  ? ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isScanned = !isScanned;
                        });
                        _createProduct(context);
                      },
                      icon: const Icon(Icons.barcode_reader),
                      label: const Text('Resume'),
                    )
                  : Container()
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
              icon: const Icon(Icons.barcode_reader))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 150,
              width: double.infinity,
              child: result != null
                  ? ListView(
                      children: [
                        Container(
                          height: 100,
                          child: SfBarcodeGenerator(
                            value: result!.code,
                            showValue: true,
                            textSpacing: 10,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isScanned = !isScanned;
                            });
                            _createProduct(context);
                          },
                          icon: const Icon(Icons.barcode_reader),
                          label: const Text('Resume'),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: () => _createProduct(context),
                      child: const Text('Scan Now')),
            ),
            const SizedBox(
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
            const SizedBox(
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
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                if (productName == null || productPrice == null) {
                  Alert(context, 'Product name and price required');
                } else {
                  Provider.of<ProductProvider>(context, listen: false)
                      .addProduct(productName!, productPrice!, result)
                      .then(
                        (value) => value
                            ? Alert(context, 'Successfully Added')
                            : Alert(context, 'Already Exists Bar Code'),
                      );
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 60,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void Alert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
