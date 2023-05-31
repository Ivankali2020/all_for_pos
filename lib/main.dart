import 'package:flutter/material.dart';
import 'package:pos/Helper/Db.dart';
import 'package:pos/Providers/CategoryProvider.dart';
import '../Screen/Category/CreateCategory.dart';
import '../Providers/OrderProvider.dart';
import '../Screen/OrderDetailScreen.dart';
import '../Screen/OrderScreen.dart';
import './Screen/CustomPrint.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ProductProvider()),
        ChangeNotifierProvider.value(value: OrderProvider()),
        ChangeNotifierProvider.value(value: CategoryProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            accentColor: Color.fromARGB(255, 241, 250, 255)),
        home: HomeScreen(),
        routes: {
          'create': (context) => CreateProduct(),
          'sale': (context) => SaleProduct(),
          'print': (context) => CustomPrint(),
          'printCustom': (context) => CustomPrint(),
          'orders': (context) => OrderScreen(),
          'detail': (context) => OrderDetailScreen(),
          'home': (context) => HomeScreen(),
          'category': (context) => CreateCategory()
        },
      ),
    );
  }
}
// ChangeNotifierProvider.value(
//       value: ProductProvider(),
//       child: MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//           accentColor: Colors.lightBlueAccent
//         ),
//         home: HomeScreen(),
//         routes: {
//           'create':(context) => CreateProduct(),
//           'sale':(context) => SaleProduct(),
//           'print' : (context) => PrintScreen(),
//           'printCustom' : (context) => CustomPrint(),
//           'orders' : (context) => OrderScreen(),
//         },
//       ),
//     );