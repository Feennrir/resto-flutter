import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/models/dish_category.dart';

import '../models/dish.dart';
import '../services/api_service.dart';

class DishRepository {
  final ApiService _apiService = ApiService();

  // Récupérer tous les plats
  Future<List<Dish>> getAllDishes() async {
    try {
      final response = await _apiService.get('/dishes');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dish.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des plats');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer un plat par ID
  Future<Dish> getDishById(int id) async {
    try {
      final response = await _apiService.get('/dishes/$id');

      if (response.statusCode == 200) {
        return Dish.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Plat non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les plats par catégorie
  Future<List<Dish>> getDishesByCategory(DishCategory category) async {
    final allDishes = await getAllDishes();
    return allDishes.where((dish) => dish.category.name == category.name).toList();
  }
}