import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/models/dish.dart';
import 'package:restaurant_menu/models/dish_category.dart';
import 'package:restaurant_menu/repositories/dish_repository.dart';

class MenuScreenViewModel {
  ValueNotifier<List<Dish>> dishesNotifier = ValueNotifier<List<Dish>>([]);
  ValueNotifier<DishCategory> selectedCategoryNotifier =
      ValueNotifier<DishCategory>(DishCategory.values.first);
  DishRepository dishRepository = DishRepository();

  Future<void> init() async {
    await dishRepository.getDishesByCategory(DishCategory.values.first).then((dishes) {
      dishesNotifier.value = dishes;
    });
  }

  Future<void> fetchByCategory(String category) async {
    DishCategory categoryObject = DishCategory.values.firstWhere(
            (e) => e.name.toLowerCase() == category.toLowerCase(),
        orElse: () => DishCategory.values.first);
    await dishRepository
        .getDishesByCategory(categoryObject)
        .then((dishes) {
      dishesNotifier.value = dishes;
      selectedCategoryNotifier.value = categoryObject;
    });
  }
}