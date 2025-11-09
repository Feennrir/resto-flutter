import 'dart:convert';

import 'package:restaurant_menu/models/reservation.dart';
import 'package:restaurant_menu/services/api_service.dart';

import 'auth_repository.dart';

class ReservationRepository {
  final ApiService _apiService = ApiService();
  final AuthRepository _authRepository = AuthRepository();

  ReservationRepository();

  // Créer une nouvelle réservation
  Future<Reservation> createReservation({
    required String userId,
    required String restaurantId,
    required String date,
    required String time,
    required int partySize,
    String? specialRequests,
  }) async {
    try {
      final token = await _authRepository.getToken();
      final Map<String, dynamic> requestBody = {
        'userId': userId,
        'restaurantId': restaurantId,
        'date': date,
        'time': time,
        'partySize': partySize,
        'specialRequests': specialRequests ?? '',
      };

      final response = await _apiService.post(
        '/reservations', requestBody, token: token
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Reservation.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la création de la réservation');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Vérifier la disponibilité
  Future<Map<String, dynamic>> checkAvailability({
    required String restaurantId,
    required String date,
    required String time,
    required int partySize,
  }) async {
    try {
      final queryParams = {
        'restaurantId': restaurantId,
        'date': date,
        'time': time,
        'partySize': partySize.toString(),
      };

      final response = await _apiService.get('/api/reservations/availability?' +
          queryParams.entries.map((e) => '${e.key}=${e.value}').join('&'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de la vérification de disponibilité');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les réservations par date
  Future<List<Reservation>> getReservationsByDate({
    required String restaurantId,
    required String date,
  }) async {
    try {
      final response = await _apiService.get('/api/reservations/$restaurantId/$date');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reservation.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors du chargement des réservations');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableTimeSlots({
    required String restaurantId,
    required String date,
  }) async {
    try {
      final response = await _apiService.get('/reservations/available-slots/$restaurantId/$date');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> availableSlots = responseBody['availableSlots'] as List;

        return availableSlots
            .map((slot) => {
              'time': slot['time'] as String,
              'availableSpaces': slot['availableSpaces'] as int,
              'maxCapacity': slot['maxCapacity'] as int,
            })
            .where((slot) => (slot['time'] as String).isNotEmpty)
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors du chargement des créneaux disponibles');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Annuler une réservation
  Future<bool> cancelReservation({required int reservationId}) async {
    try {
      final token = await _authRepository.getToken();

      final response = await _apiService.delete(
        '/reservations/$reservationId',
        token: token,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors de l\'annulation de la réservation');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}