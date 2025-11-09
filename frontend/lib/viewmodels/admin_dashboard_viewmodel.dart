import 'package:flutter/foundation.dart';
import '../repositories/admin_repository.dart';

class AdminDashboardViewModel {
  final AdminRepository _adminRepository = AdminRepository();

  final ValueNotifier<int> totalDishes = ValueNotifier(0);
  final ValueNotifier<int> availableDishes = ValueNotifier(0);
  final ValueNotifier<int> pendingReservations = ValueNotifier(0);
  final ValueNotifier<int> todayReservations = ValueNotifier(0);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> initialize() async {
    isLoading.value = true;
    error.value = null;

    try {
      final stats = await _adminRepository.getStats();

      totalDishes.value = stats.totalDishes;
      availableDishes.value = stats.availableDishes;
      pendingReservations.value = stats.pendingReservations;
      todayReservations.value = stats.todayReservations;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Erreur lors du chargement des stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    totalDishes.dispose();
    availableDishes.dispose();
    pendingReservations.dispose();
    todayReservations.dispose();
    isLoading.dispose();
    error.dispose();
  }
}