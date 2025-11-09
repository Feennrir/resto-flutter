import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_menu/repositories/dto/reservation_profile_dto.dart';
import 'package:restaurant_menu/repositories/reservation_repository.dart';

import '../models/reservation.dart';

class ReservationEditSheetModel extends ChangeNotifier {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ReservationRepository _reservationRepository = ReservationRepository();

  Future<void> cancelReservation(ReservationProfileDto reservation) async {
    bool result = await _reservationRepository.cancelReservation(reservationId: reservation.id);
    if (result) {
      // Changer le statut de la réservation annulée dans la liste
      ReservationProfileDto cancelledReservation = ReservationProfileDto(
        id: reservation.id,
        date: reservation.date,
        time: reservation.time,
        status: 'Cancelled',
        guests: reservation.guests,
        specialRequests: reservation.specialRequests,
        isUpcoming: reservation.isUpcoming,
      );
      // int index = reservations.value.indexOf(updatedReservations);
      // reservations.value[index] = cancelledReservation;
      notifyListeners();
    }
  }

  Future updateReservation({required ReservationProfileDto oldReservation, DateTime? date, TimeOfDay? time, String? specialRequests, int guests = 0}) async {
    ReservationProfileDto newReservation = ReservationProfileDto(
      id: oldReservation.id,
      date: date != null ? date.toIso8601String() : oldReservation.date,
      time: time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : oldReservation.time,
      status: ReservationStatus.pending.name,
      guests: guests != 0 ? guests : oldReservation.guests,
      specialRequests: specialRequests ?? oldReservation.specialRequests,
      isUpcoming: oldReservation.isUpcoming,
    );
    await _reservationRepository.updateReservation(reservation: newReservation);
  }
}