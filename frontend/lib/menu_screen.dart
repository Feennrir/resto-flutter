import 'package:flutter/cupertino.dart';

import 'cart_screen.dart';
import 'dish_card.dart';
import 'model/dish.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCategory = 'Formules';

  final List<String> categories = [
    'Formules',
    'Entrées',
    'Plats',
    'Desserts',
    'Boissons',
  ];

  final List<Dish> dishes = [
    // Formules
    Dish(
      name: 'Menu Découverte',
      category: 'Formules',
      price: 29.90,
      description: 'Entrée + Plat + Dessert au choix',
      imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
    ),
    Dish(
      name: 'Menu Express',
      category: 'Formules',
      price: 19.90,
      description: 'Plat + Boisson du jour',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    ),
    Dish(
      name: 'Menu Dégustation',
      category: 'Formules',
      price: 45.00,
      description: 'Entrée + Plat + Dessert + Vin',
      imageUrl: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
    ),
    // Entrées
    Dish(
      name: 'Salade César',
      category: 'Entrées',
      price: 8.50,
      description: 'Laitue romaine, poulet grillé, parmesan, croûtons',
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
    ),
    Dish(
      name: 'Soupe à l\'oignon',
      category: 'Entrées',
      price: 7.00,
      description: 'Gratinée au fromage, servie avec croûtons',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
    ),
    Dish(
      name: 'Carpaccio de bœuf',
      category: 'Entrées',
      price: 12.00,
      description: 'Fines tranches de bœuf, roquette, parmesan',
      imageUrl: 'https://images.unsplash.com/photo-1595777216528-07273d63c50f?w=400',
    ),
    // Plats
    Dish(
      name: 'Entrecôte grillée',
      category: 'Plats',
      price: 24.00,
      description: 'Viande de bœuf, frites maison, sauce au poivre',
      imageUrl: 'https://images.unsplash.com/photo-1558030006-450675393462?w=400',
    ),
    Dish(
      name: 'Saumon en papillote',
      category: 'Plats',
      price: 22.00,
      description: 'Légumes de saison, riz basmati, sauce citron',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400',
    ),
    Dish(
      name: 'Risotto aux champignons',
      category: 'Plats',
      price: 18.00,
      description: 'Riz arborio, cèpes, parmesan, truffe',
      imageUrl: 'https://images.unsplash.com/photo-1476124369491-c4bffd7a45c2?w=400',
    ),
    Dish(
      name: 'Pizza Margherita',
      category: 'Plats',
      price: 14.00,
      description: 'Tomate, mozzarella, basilic frais',
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
    ),
    // Desserts
    Dish(
      name: 'Tiramisu maison',
      category: 'Desserts',
      price: 7.50,
      description: 'Mascarpone, café, cacao, biscuit',
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
    ),
    Dish(
      name: 'Tarte Tatin',
      category: 'Desserts',
      price: 8.00,
      description: 'Pommes caramélisées, pâte feuilletée, glace vanille',
      imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
    ),
    Dish(
      name: 'Mousse au chocolat',
      category: 'Desserts',
      price: 6.50,
      description: 'Chocolat noir 70%, chantilly maison',
      imageUrl: 'https://images.unsplash.com/photo-1541599468348-e96984315921?w=400',
    ),
    // Boissons
    Dish(
      name: 'Vin rouge Bordeaux',
      category: 'Boissons',
      price: 5.50,
      description: 'Verre de vin rouge AOC, 15cl',
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=400',
    ),
    Dish(
      name: 'Café espresso',
      category: 'Boissons',
      price: 2.50,
      description: 'Café torréfié, servi avec un carré de chocolat',
      imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400',
    ),
    Dish(
      name: 'Eau minérale',
      category: 'Boissons',
      price: 3.00,
      description: 'Bouteille 50cl, plate ou pétillante',
      imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400',
    ),
  ];

  List<Dish> get filteredDishes {
    return dishes.where((dish) => dish.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Menu du Restaurant Le Gourmet'),
        backgroundColor: CupertinoColors.systemBackground,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.cart),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
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
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoColors.systemOrange
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
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
      ),
    );
  }

  Widget _buildDishList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        return DishCard(dish: filteredDishes[index]);
      },
    );
  }
}