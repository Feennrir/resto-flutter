import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';
import 'auth_repository.dart';

class UserRepository {
  final ApiService _apiService = ApiService();
  final AuthRepository _authRepository = AuthRepository();

  // Récupérer le profil de l'utilisateur connecté
  Future<User?> getProfile() async {
    try {
      final token = await _authRepository.getToken();
      
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _apiService.get('/auth/profile', token: token);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors du chargement du profil');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour le profil
  Future<User> updateProfile({String? name, String? phone}) async {
    try {
      final token = await _authRepository.getToken();
      
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final response = await _apiService.put(
        '/auth/profile',
        body,
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}