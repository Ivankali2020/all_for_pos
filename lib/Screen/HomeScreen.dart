import 'package:flutter/material.dart';
import '../Models/TransitionPage.dart';
import '../Screen/CreateProduct.dart';
import '../Screen/SaleProduct.dart';
import '../Widegets/DrawerWidget.dart';
import '../Widegets/ProductsWidgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../Providers/ProductProvider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OM POS'),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).pushNamed('printCustom');
          //   },
          //   icon:const Icon(Icons.print_outlined),
          // ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(fadePageRoute('sale',SaleProduct()));
            },
            icon: Icon(Icons.print),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(fadePageRoute('routeName', CreateProduct()));
            },
            icon: Icon(Icons.add),
          ),
          // IconButton(
          //   onPressed: () async {
          //     await Provider.of<ProductProvider>(context, listen: false)
          //         .deleteTabale();
          //   },
          //   icon: Icon(Icons.delete),
          // )
        ],
      ),
      drawer: DrawerWidget(),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context).fetchDatas(),
        builder: (context, value) => value.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : const ProductWidgets(),
      ),
    );
  }
}
