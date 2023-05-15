import 'package:flutter/material.dart';
import './Screen/CustomPrint.dart';
import './Screen/PrintScreen.dart';
import './Screen/SaleProduct.dart';
import './Screen/CreateProduct.dart';
import './Providers/ProductProvider.dart';
import 'package:provider/provider.dart';
import './Screen/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProductProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.lightBlueAccent
        ),
        home: HomeScreen(),
        routes: {
          'create':(context) => CreateProduct(),
          'sale':(context) => SaleProduct(),
          'print' : (context) => PrintScreen(),
          'printCustom' : (context) => CustomPrint()
        },
      ),
    );
  }
}
