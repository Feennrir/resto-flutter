import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/repositories/user_repository.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  ValueNotifier<bool> isSaving = ValueNotifier(false);
  ValueNotifier<String> errorMessage = ValueNotifier("");

  /// Mettre à jour le profil utilisateur
  /// @param {String?} name - Le nouveau nom de l'utilisateur
  /// @param {String?} phone - Le nouveau numéro de téléphone de l'utilisateur
  /// @return Future<bool> - true si la mise à jour a réussi, false sinon
  /// @throws Exception si une erreur se produit lors de la mise à jour
  Future<bool> updateProfile({String? name, String? phone}) async {
    isSaving.value = true;
    errorMessage.value = "";

    try {
      await _userRepository.updateProfile(name: name, phone: phone);
      isSaving.value = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      isSaving.value = false;
      return false;
    }
  }
}