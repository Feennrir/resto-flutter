import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'presentation/main_tab_view.dart';
import 'utils/colors.dart' as app_colors;

void main() {
  runApp(const RestaurantMenuApp());
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

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
