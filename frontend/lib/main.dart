import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main_tab_view.dart';
import 'restaurant_presentation_screen.dart';
import 'colors.dart' as app_colors;

void main() {
  runApp(const RestaurantMenuApp());
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Le Gourmet Restaurant',
      theme: CupertinoThemeData(
        primaryColor: app_colors.Colors.primary,
        brightness: Brightness.light,
      ),
      home: MainTabView(),
    );
  }
}
