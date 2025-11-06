import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/service/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await _cartService.loadCart();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mon Panier'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _cartService.items.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _cartService.items.length,
                itemBuilder: (context, index) {
                  final item = _cartService.items[index];
                  return CupertinoListTile(
                    leading: Image.network(
                      item.dish.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.dish.name),
                    subtitle: Text('${item.dish.price}€'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.minus_circle),
                          onPressed: () async {
                            if (item.quantity > 1) {
                              await _cartService.updateQuantity(
                                item.dish.name,
                                item.quantity - 1,
                              );
                            } else {
                              await _cartService.removeItem(item.dish.name);
                            }
                            setState(() {});
                          },
                        ),
                        Text('${item.quantity}'),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.plus_circle),
                          onPressed: () async {
                            await _cartService.updateQuantity(
                              item.dish.name,
                              item.quantity + 1,
                            );
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey4,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_cartService.total.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      child: const Text('Commander'),
                      onPressed: () {
                        // Action de commande
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
