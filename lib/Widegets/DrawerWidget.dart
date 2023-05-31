import 'package:flutter/material.dart';
import 'package:pos/Screen/Category/CreateCategory.dart';
import 'package:pos/Screen/OrderScreen.dart';
import '../Models/TransitionPage.dart';
import '../Screen/Dashboard.dart';
import '../Screen/HomeScreen.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({super.key});

  final List<Map<String, dynamic>> menus = [
    {'name': 'Dashboard', 'route': const Dasboard(), 'route_name': 'dashboard'},
    {'name': 'Category', 'route': const CreateCategory(), 'route_name': 'category'},
    {'name': 'Orders', 'route': const OrderScreen(), 'route_name': 'order'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
               const SizedBox(
                width: double.infinity,
                height: 100,
              ),
              ...menus.map((e) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(fadePageRoute(e['route_name'], e['route']));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    alignment: Alignment.center,
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Text(e['name']),
                  ),
                );
              }).toList(),

            ],
          ),
        ),
      ),
    );
  }
}
