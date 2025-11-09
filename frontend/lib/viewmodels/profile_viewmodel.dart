import 'package:flutter/foundation.dart';
import 'package:flutter/src/material/time.dart';
import 'package:restaurant_menu/models/reservation.dart';
import 'package:restaurant_menu/repositories/reservation_repository.dart';
import '../models/user.dart';
import '../repositories/dto/reservation_profile_dto.dart';
import '../repositories/user_repository.dart';

class ProfileViewModel {
  final UserRepository _userRepository = UserRepository();
  final ReservationRepository _reservationRepository = ReservationRepository();

  final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<List<ReservationProfileDto>> reservations = ValueNotifier<List<ReservationProfileDto>>([]);


  User? get user => userNotifier.value;
  bool get isLoading => isLoadingNotifier.value;
  String? get errorMessage => errorMessageNotifier.value;

  /// Charger le profil utilisateur
  /// @return Future<void>
  /// @throws Exception si une erreur se produit lors du chargement
  Future<void> loadProfile() async {
    isLoadingNotifier.value = true;
    errorMessageNotifier.value = null;

    try {
      final loadedUser = await _userRepository.getProfile();
      final reservationList = await _userRepository.getUserReservations(userId : loadedUser!.id);
      userNotifier.value = loadedUser;
      reservations.value = reservationList;
      isLoadingNotifier.value = false;
    } catch (e) {
      errorMessageNotifier.value = e.toString();
      isLoadingNotifier.value = false;
    }
  }


  /// Mettre à jour le profil utilisateur
  /// @param {String?} name - Le nouveau nom de l'utilisateur
  /// @param {String?} phone - Le nouveau numéro de téléphone de l'utilisateur
  /// @return Future<bool> - true si la mise à jour a réussi, false sinon
  /// @throws Exception si une erreur se produit lors de la mise à jour
  Future<bool> updateProfile({String? name, String? phone}) async {
    isLoadingNotifier.value = true;
    errorMessageNotifier.value = null;

    try {
      final updatedUser = await _userRepository.updateProfile(name: name, phone: phone);
      userNotifier.value = updatedUser;
      isLoadingNotifier.value = false;
      return true;
    } catch (e) {
      errorMessageNotifier.value = e.toString();
      isLoadingNotifier.value = false;
      return false;
    }
  }


  void clearError() {
    errorMessageNotifier.value = null;
  }

  void clear() {
    userNotifier.value = null;
    errorMessageNotifier.value = null;
  }

  /// Dispose des notifiers
  /// @return void
  void dispose() {
    userNotifier.dispose();
    isLoadingNotifier.dispose();
    errorMessageNotifier.dispose();
    reservations.dispose();
  }

  void cancelReservation(int id) async {
    bool result = await _reservationRepository.cancelReservation(reservationId: id);
    if (result) {
      // Changer le statut de la réservation annulée dans la liste
      ReservationProfileDto updatedReservations = reservations.value.firstWhere((res) => res.id == id);
      ReservationProfileDto cancelledReservation = ReservationProfileDto(
        id: updatedReservations.id,
        date: updatedReservations.date,
        time: updatedReservations.time,
        status: 'Cancelled',
        guests: updatedReservations.guests,
        specialRequests: updatedReservations.specialRequests,
        isUpcoming: updatedReservations.isUpcoming,
      );
      int index = reservations.value.indexOf(updatedReservations);
      reservations.value[index] = cancelledReservation;
    }
  }

  Future updateReservation({required int id, DateTime? date, TimeOfDay? time, String? specialRequests, int guests = 0}) async {
    ReservationProfileDto updatedReservations = reservations.value.firstWhere((res) => res.id == id);
    ReservationProfileDto newReservation = ReservationProfileDto(
      id: updatedReservations.id,
      date: date != null ? date.toIso8601String() : updatedReservations.date,
      time: time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : updatedReservations.time,
      status: ReservationStatus.pending.name,
      guests: guests != 0 ? guests : updatedReservations.guests,
      specialRequests: specialRequests ?? updatedReservations.specialRequests,
      isUpcoming: updatedReservations.isUpcoming,
    );
    bool result = await _reservationRepository.updateReservation(reservation: newReservation);
    // if (result) {
    //   // Mettre à jour la réservation dans la liste
    //   ReservationProfileDto updatedReservations = reservations.value.firstWhere((res) => res.id == id);
    //   int index = reservations.value.indexOf(updatedReservations);
    //   reservations.value[index] = newReservation;
    // }
  }
}