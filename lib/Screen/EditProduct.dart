import 'package:flutter/material.dart';
import 'package:greate_places/Models/Product.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../Providers/ProductProvider.dart';
import 'package:provider/provider.dart';

class EditProduct extends StatefulWidget {
  Product product;
  final key;

  EditProduct(this.product, {required this.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    nameController.text = widget.product.name;
    priceController.text = widget.product.price.toString();
    super.initState();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
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
          Navigator.of(context).pop();
        } else {
          setState(() {
            result = scanData;
            isScanned = !isScanned;
            controller.pauseCamera();
            return;
          });
        }
      });
    });
  }

  void _EditProduct(ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              isScanned
                  ? Column(
                      children: [
                        Container(
                          height: 100,
                          child: result != null
                              ? SfBarcodeGenerator(value: result!.code)
                              : SfBarcodeGenerator(
                                  value: widget.product.barcode),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isScanned = false;
                              Navigator.of(context).pop();
                            });
                          },
                          child: const Text('Restart Scan'),
                        )
                      ],
                    )
                  : Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(width: .5, color: Colors.black)),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: scanBarCode,
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
        title: const Text('Edit Product'),
        actions: [
          IconButton(
              onPressed: () => _EditProduct(context),
              icon: const Icon(Icons.barcode_reader))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 100,
              width: 300,
              child: result != null
                  ? SfBarcodeGenerator(
                      value: result!.code,
                      showValue: true,
                      textSpacing: 10,
                    )
                  : SfBarcodeGenerator(
                      value: widget.product.barcode,
                      showValue: true,
                      textSpacing: 10,
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(gapPadding: 1),
              ),
              controller: nameController,
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
              controller: priceController,
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (nameController.text == null ||
                    priceController.text == null) {
                  Alert(context, 'Product name and price required');
                } else {
                 await Provider.of<ProductProvider>(context, listen: false)
                      .editProduct(
                          nameController.text,
                          int.parse(priceController.text),
                          result != null
                              ? result!.code
                              : widget.product.barcode,
                          widget.product.id)
                      .then((value) => value
                          ? Alert(context, 'Successfully Added')
                          : Alert(context, 'Already Exists Bar Code'));
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  void Alert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Color.fromARGB(255, 179, 245, 176),
    ));
  }
}
