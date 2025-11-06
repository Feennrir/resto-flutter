import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/service/cart_service.dart';

import 'model/dish.dart';

class DishDetailScreen extends StatelessWidget {
  final Dish dish;

  const DishDetailScreen({Key? key, required this.dish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(dish.name),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                dish.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: CupertinoColors.systemGrey5,
                    child: const Icon(
                      CupertinoIcons.photo,
                      size: 80,
                      color: CupertinoColors.systemGrey,
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${dish.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dish.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dish.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            CupertinoIcons.time,
                            'Temps de préparation',
                            '15-20 min',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            CupertinoIcons.flame,
                            'Calories estimées',
                            '450 kcal',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            CupertinoIcons.star_fill,
                            'Note moyenne',
                            '4.5/5',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.systemOrange,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Ajouter à la commande',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                        onPressed: () => _showQuantityPicker(context, dish)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemOrange,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  void _showQuantityPicker(BuildContext context, Dish dish) {
    int selectedQuantity = 1;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Quantité'),
        content: SizedBox(
          height: 120,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              selectedQuantity = index + 1;
            },
            children: List.generate(
              10,
                  (index) => Center(child: Text('${index + 1}')),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ajouter'),
            onPressed: () async {
              final cartService = CartService();
              await cartService.loadCart();

              for (int i = 0; i < selectedQuantity; i++) {
                await cartService.addItem(dish);
              }

              if (context.mounted) {
                Navigator.pop(context);
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Ajouté !'),
                    content: Text(
                      '$selectedQuantity x ${dish.name} ajouté(s) à votre commande.',
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }


}