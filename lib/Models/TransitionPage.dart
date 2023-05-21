import 'package:flutter/material.dart';

 Route<dynamic> fadePageRoute(String routeName, Widget page, {Object? arguments}) {
  return PageRouteBuilder<dynamic>(
    settings: RouteSettings(name: routeName, arguments: arguments),
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return page;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    },
  );
}
