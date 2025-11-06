import 'dish.dart';

class CartItem {
  final Dish dish;
  int quantity;

  CartItem({required this.dish, this.quantity = 1});

  Map<String, dynamic> toJson() => {
    'dish': {
      'name': dish.name,
      'description': dish.description,
      'price': dish.price,
      'imageUrl': dish.imageUrl,
      'category': dish.category,
    },
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    dish: Dish(
      name: json['dish']['name'],
      description: json['dish']['description'],
      price: json['dish']['price'],
      imageUrl: json['dish']['imageUrl'],
      category: json['dish']['category'],
    ),
    quantity: json['quantity'],
  );
}