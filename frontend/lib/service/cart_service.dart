import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/card_item.dart';
import '../model/dish.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(
      0, (sum, item) => sum + (item.dish.price * item.quantity)
  );

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      _items.clear();
      _items.addAll(decoded.map((json) => CartItem.fromJson(json)));
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, encoded);
  }

  Future<void> addItem(Dish dish) async {
    final existingIndex = _items.indexWhere((item) => item.dish.name == dish.name);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(dish: dish));
    }

    await _saveCart();
  }

  Future<void> removeItem(String dishName) async {
    _items.removeWhere((item) => item.dish.name == dishName);
    await _saveCart();
  }

  Future<void> updateQuantity(String dishName, int quantity) async {
    final item = _items.firstWhere((item) => item.dish.name == dishName);
    item.quantity = quantity;
    await _saveCart();
  }

  Future<void> clear() async {
    _items.clear();
    await _saveCart();
  }
}