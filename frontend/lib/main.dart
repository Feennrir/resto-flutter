import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'menu_screen.dart';

void main() {
  runApp(const RestaurantMenuApp());
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Menu Restaurant',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemOrange,
        brightness: Brightness.light,
      ),
      home: MenuScreen(),
    );
  }
}
