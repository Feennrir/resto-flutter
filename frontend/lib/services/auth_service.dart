import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;

  /// Simule la connexion d'un utilisateur
  /// @param email L'email de l'utilisateur
  /// @param password Le mot de passe de l'utilisateur
  /// @return true si la connexion est réussie, false sinon
  Future<bool> login(String email, String password) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 2));
    
    // Simuler une authentification (à remplacer par un vrai appel API)
    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Simule l'inscription d'un utilisateur
  /// @param name Le nom de l'utilisateur
  /// @param email L'email de l'utilisateur
  /// @param password Le mot de passe de l'utilisateur
  /// @return true si l'inscription est réussie, false sinon
  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }
}