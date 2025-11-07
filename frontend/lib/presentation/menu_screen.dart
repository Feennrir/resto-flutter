import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/models/dish_category.dart';
import 'package:restaurant_menu/presentation/widget/dish_card.dart';
import 'package:restaurant_menu/utils/colors.dart';

import '../viewmodels/menu_screen_viewmodel.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  MenuScreenViewModel viewModel = MenuScreenViewModel();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Menu du Restaurant Le Gourmet'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildCategorySelector(),
            Expanded(
              child: _buildDishList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 35,
      child: ValueListenableBuilder(
        valueListenable: viewModel.selectedCategoryNotifier,
        builder: (context, category, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: DishCategory.values.length,
            itemBuilder: (context, index) {
              final category = DishCategory.values[index].name;
              final isSelected = category == viewModel.selectedCategoryNotifier.value.name;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () async {
                    await viewModel.fetchByCategory(category);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.primary
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.capitalize(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }

  Widget _buildDishList() {
    return FutureBuilder(
      future: viewModel.init(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return ValueListenableBuilder(
          valueListenable: viewModel.dishesNotifier,
          builder: (context, filteredDishes, _) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDishes.length,
              itemBuilder: (context, index) {
                return DishCard(dish: filteredDishes[index]);
              },
            );
          }
        );
      }
    );
  }
}

extension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}