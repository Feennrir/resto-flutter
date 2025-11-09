import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/models/reservation.dart';
import 'package:restaurant_menu/repositories/auth_repository.dart';
import 'package:restaurant_menu/repositories/reservation_repository.dart';

class ReservationScreenViewModel {
  final ReservationRepository reservationRepository = ReservationRepository();
  final AuthRepository authRepository = AuthRepository();

  ReservationScreenViewModel();

  late Reservation reservation;

  final DateTime _initialDate = DateTime.now();

  late final ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(_initialDate);
  late final ValueNotifier<DateTime> minimumDate = ValueNotifier<DateTime>(_initialDate);
  final ValueNotifier<String?> selectedTime = ValueNotifier<String?>(null);
  final ValueNotifier<int> numberOfGuests = ValueNotifier<int>(2);
  final ValueNotifier<List<Map<String, dynamic>>> availableTimes = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<String> specialRequests = ValueNotifier<String>('');
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void dispose() {
    selectedDate.dispose();
    minimumDate.dispose();
    selectedTime.dispose();
    numberOfGuests.dispose();
    specialRequests.dispose();
    isLoading.dispose();
  }

  Future<void> createReservation({
    required String restaurantId,
  }) async {
    isLoading.value = true;
    try {
      final user = await authRepository.getStoredUser();
      reservation = await reservationRepository.createReservation(
        userId: user!.id.toString(),
        restaurantId: restaurantId,
        date: selectedDate.value.toIso8601String().split('T')[0],
        time: selectedTime.value!,
        partySize: numberOfGuests.value,
        specialRequests: specialRequests.value.isNotEmpty ? specialRequests.value : null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAvailableTimeSlots({
    required String restaurantId,
  }) async {
    try {
      final timeSlots = await reservationRepository.getAvailableTimeSlots(
        restaurantId: restaurantId,
        date: selectedDate.value.toIso8601String().split('T')[0],
      );
      availableTimes.value = timeSlots;
      if (selectedTime.value != null && 
          !timeSlots.any((slot) => slot['time'] == selectedTime.value)) {
        selectedTime.value = null;
      }
    } catch (e) {
      availableTimes.value = [];
      selectedTime.value = null;
    }
  }

  void updateSelectedDate(DateTime date) {
    if (date.isBefore(minimumDate.value)) {
      selectedDate.value = minimumDate.value;
    } else {
      selectedDate.value = date;
    }
    selectedTime.value = null;
  }

  void updateNumberOfGuests(int guests) {
    numberOfGuests.value = guests;
  }

  void updateSelectedTime(String? time) {
    selectedTime.value = time;
  }

  void updateSpecialRequests(String requests) {
    specialRequests.value = requests;
  }
}
