import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configuration de l'URL de base
  // Android Emulator: http://10.0.2.2:3000
  // iOS Simulator: http://localhost:3000
  // Device physique: http://YOUR_LOCAL_IP:3000
  static const String baseUrl = 'http://localhost:3000/api';

  // Headers communs
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Méthode GET
  Future<http.Response> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.get(uri, headers: _getHeaders(token: token));
  }

  // Méthode POST
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
  }

  // Méthode PUT
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      uri,
      headers: _getHeaders(token: token),
      body: jsonEncode(body),
    );
  }

  // Méthode DELETE
  Future<http.Response> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.delete(uri, headers: _getHeaders(token: token));
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}