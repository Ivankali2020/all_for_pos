import 'package:flutter/material.dart';
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
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('printCustom');
            },
            icon: Icon(Icons.print_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('sale');
            },
            icon: Icon(Icons.print),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('create');
            },
            icon: Icon(Icons.add),
          ),


          IconButton(
            onPressed: () async {
              await Provider.of<ProductProvider>(context, listen: false)
                  .deleteTabale();
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context).fetchDatas(),
        builder: (context, value) =>
            value.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Consumer<ProductProvider>(
                    // child: const Center(child: Text('No Place Found')),
                    builder: (context, value, child) => value.items.length > 0
                        ? ListView.builder(
                            itemCount: value.items.length,
                            itemBuilder: (ctx, i) => ListTile(
                                  title: Text('${value.items[i].name}'),
                                  subtitle: Text(
                                      'PRICE : ${value.items[i].price} , BARCODE : ${value.items[i].barcode}'),
                                ))
                        : const Center(
                            child: Text('No Products Found'),
                          ),
                  ),
      ),
    );
  }
}
