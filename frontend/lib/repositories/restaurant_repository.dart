import 'dart:convert';
import 'package:restaurant_menu/services/api_service.dart';

class RestaurantInfo {
  final int id;
  final String name;
  final int maxCapacity;
  final String openingTime;
  final String closingTime;
  final int serviceDuration;
  final String? phone;
  final String? address;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  RestaurantInfo({
    required this.id,
    required this.name,
    required this.maxCapacity,
    required this.openingTime,
    required this.closingTime,
    required this.serviceDuration,
    this.phone,
    this.address,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['id'],
      name: json['name'],
      maxCapacity: json['maxCapacity'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      serviceDuration: json['serviceDuration'],
      phone: json['phone'],
      address: json['address'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  // Formater les heures pour l'affichage
  String get formattedHours {
    final opening = _formatTime(openingTime);
    final closing = _formatTime(closingTime);
    return '$opening - $closing';
  }

  String _formatTime(String time) {
    // time format: "11:00:00" -> "11h00"
    final parts = time.split(':');
    return '${parts[0]}h${parts[1]}';
  }
}

class RestaurantRepository {
  final ApiService _apiService = ApiService();

  Future<RestaurantInfo> getRestaurantInfo(String restaurantId) async {
    try {
      final response = await _apiService.get('/restaurant/$restaurantId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RestaurantInfo.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur lors du chargement des informations du restaurant');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
