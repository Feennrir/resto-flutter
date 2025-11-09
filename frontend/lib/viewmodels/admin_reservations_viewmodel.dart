import 'package:flutter/foundation.dart';
import '../repositories/admin_repository.dart';
import '../repositories/dto/admin_reservation_dto.dart';

class AdminReservationsViewModel {
  final AdminRepository _adminRepository = AdminRepository();

  final ValueNotifier<List<AdminReservationDTO>> pendingReservations = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> loadPendingReservations() async {
    isLoading.value = true;
    error.value = null;

    try {
      final result = await _adminRepository.getPendingReservations();
      pendingReservations.value = result
          .map((json) => AdminReservationDTO.fromJson(json))
          .toList();
    } catch (e) {
      error.value = e.toString();
      debugPrint('Erreur lors du chargement des réservations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> acceptReservation(int id) async {
    try {
      await _adminRepository.acceptReservation(id);
      // Retirer la réservation de la liste
      pendingReservations.value = pendingReservations.value
          .where((r) => r.id != id)
          .toList();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Erreur lors de l\'acceptation: $e');
      return false;
    }
  }

  Future<bool> rejectReservation(int id) async {
    try {
      await _adminRepository.rejectReservation(id);
      // Retirer la réservation de la liste
      pendingReservations.value = pendingReservations.value
          .where((r) => r.id != id)
          .toList();
      return true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Erreur lors du refus: $e');
      return false;
    }
  }

  void dispose() {
    pendingReservations.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
