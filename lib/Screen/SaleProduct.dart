import 'package:flutter/material.dart';
import 'package:greate_places/Models/Sale.dart';
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Success',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ));
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
                  padding: EdgeInsets.all(10),
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
                            print('con');
                          },
                          icon: Icon(Icons.restore),
                          label: Text('Resume'),
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
                      icon: Icon(Icons.scanner_outlined),
                      label: Text('Scan Now')),
                ),
          SizedBox(
            height: 400,
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

class SaleProducts extends StatelessWidget {
  late List<Sale> sales = [];
  SaleProducts(this.sales);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sales.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(
                sales[i].name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Text(
                  '${sales[i].price.toString()} Ks x ${sales[i].quantity}'),
              trailing: Text('${sales[i].price * sales[i].quantity} Ks'),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Consumer<ProductProvider>(
              builder: (context, value, child) => Text(
                'TOTAL : ${value.total}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('print');
              },
              icon: Icon(Icons.print),
              label: const Text('Print'),
            )
          ],
        )
      ],
    );
  }
}
