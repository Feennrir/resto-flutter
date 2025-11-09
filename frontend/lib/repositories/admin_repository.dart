import 'dart:convert';
import '../services/api_service.dart';
import 'dto/admin_profil_dto.dart';
import 'auth_repository.dart';

class AdminRepository {
  final ApiService _apiService = ApiService();
  final AuthRepository _authRepository = AuthRepository();

  // ========== GESTION DES RÉSERVATIONS ==========

  Future<List<Map<String, dynamic>>> getPendingReservations() async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.get('/admin/reservations/pending', token: token);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des réservations en attente');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllReservations({
    String? status,
    String? date,
    int? restaurantId,
  }) async {
    try {
      final token = await _authRepository.getToken();
      String endpoint = '/admin/reservations';
      List<String> queryParams = [];

      if (status != null) queryParams.add('status=$status');
      if (date != null) queryParams.add('date=$date');
      if (restaurantId != null) queryParams.add('restaurantId=$restaurantId');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint, token: token);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des réservations');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> acceptReservation(int id) async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.put('/admin/reservations/$id/accept', {}, token: token);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de l\'acceptation de la réservation');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> rejectReservation(int id) async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.put('/admin/reservations/$id/reject', {}, token: token);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors du refus de la réservation');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> updateReservationStatus(int id, String status) async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.put('/admin/reservations/$id/status', {
        'status': status,
      }, token: token);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========== GESTION DES PLATS ==========

  Future<List<Map<String, dynamic>>> getAllDishes() async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.get('/admin/dishes', token: token);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des plats');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> createDish({
    required String name,
    String? description,
    required double price,
    required String category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.post('/admin/dishes', {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'is_available': isAvailable,
      }, token: token);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la création du plat');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> updateDish(
      int id, {
        String? name,
        String? description,
        double? price,
        String? category,
        String? imageUrl,
        bool? isAvailable,
      }) async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.put('/admin/dishes/$id', {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'is_available': isAvailable,
      }, token: token);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la mise à jour du plat');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> deleteDish(int id) async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.delete('/admin/dishes/$id', token: token);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la suppression du plat');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ========== STATISTIQUES ==========

  Future<AdminProfileDTO> getStats() async {
    try {
      final token = await _authRepository.getToken();
      final response = await _apiService.get('/admin/stats', token: token);

      if (response.statusCode == 200) {
        return AdminProfileDTO.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
