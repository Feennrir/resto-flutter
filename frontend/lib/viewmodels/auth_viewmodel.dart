import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isAuthenticated = false;
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialisation de l'état d'authentification
  /// @return Future<void>
  /// @description Vérifie si un utilisateur est déjà connecté en récupérant le token et les informations utilisateur stockées.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authRepository.getToken();
      final user = await _authRepository.getStoredUser();

      if (token != null && user != null) {
        _token = token;
        _currentUser = user;
        _isAuthenticated = true;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'initialisation: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription
  /// @return Future<bool>
  /// @description Gère le processus d'inscription en appelant le dépôt d'authentification et en mettant à jour l'état en conséquence.
  /// @param {String} name - Le nom de l'utilisateur.
  /// @param {String} email - L'email de l'utilisateur.
  /// @param {String} password - Le mot de passe de l'utilisateur.
  /// @return {bool} - Retourne true si l'inscription est réussie, sinon false.
  /// @throws {Exception} - Lance une exception en cas d'erreur inattendue.
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signup(
        name: name,
        email: email,
        password: password,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _token = result['token'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Connexion
  /// @return Future<bool>
  /// @description Gère le processus de connexion en appelant le dépôt d'authentification et en mettant à jour l'état en conséquence.
  /// @param {String} email - L'email de l'utilisateur.
  /// @param {String} password - Le mot de passe de l'utilisateur.
  /// @return {bool} - Retourne true si la connexion est réussie, sinon false.
  /// @throws {Exception} - Lance une exception en cas d'erreur inattendue.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _token = result['token'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  /// @return Future<void>
  /// @description Gère le processus de déconnexion en appelant le dépôt d'authification et en réinitialisant l'état d'authentification.
  /// @throws {Exception} - Lance une exception en cas d'erreur inattendue.
  Future<void> logout() async {
    await _authRepository.logout();
    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Réinitialiser le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}