import 'package:flutter/foundation.dart';
import 'package:restaurant_menu/repositories/restaurant_repository.dart';

class RestaurantPresentationViewModel {
  final RestaurantRepository _repository = RestaurantRepository();
  
  final ValueNotifier<RestaurantInfo?> restaurantInfo = ValueNotifier<RestaurantInfo?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  void dispose() {
    restaurantInfo.dispose();
    isLoading.dispose();
    error.dispose();
  }

  Future<void> loadRestaurantInfo(String restaurantId) async {
    isLoading.value = true;
    error.value = null;
    
    try {
      final info = await _repository.getRestaurantInfo(restaurantId);
      restaurantInfo.value = info;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Erreur lors du chargement du restaurant: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
