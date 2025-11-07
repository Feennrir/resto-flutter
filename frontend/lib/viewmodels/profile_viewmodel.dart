import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class ProfileViewModel {
  final UserRepository _userRepository = UserRepository();

  final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessageNotifier = ValueNotifier<String?>(null);

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
      userNotifier.value = loadedUser;
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
  }
}