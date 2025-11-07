import 'package:restaurant_menu/repositories/dish_repository.dart';

import 'dish_category.dart';

class Dish {
  final int id;
  final String name;
  final String description;
  final double price;
  final DishCategory category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
  });

  /// Création d'une instance de Dish à partir d'un JSON
  /// @param json Map<String, dynamic>
  /// @return Dish
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      category: DishCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == json['category'].toString().toLowerCase(),
          orElse: () => DishCategory.values.first,
        ),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convertit l'instance de Dish en JSON
  /// @return Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category.name,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}