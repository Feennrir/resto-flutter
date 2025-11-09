import 'package:flutter/foundation.dart';
import 'package:restaurant_menu/repositories/reservation_repository.dart';
import '../models/user.dart';
import '../repositories/dto/reservation_profile_dto.dart';
import '../repositories/user_repository.dart';

class ProfileViewModel {
  final UserRepository _userRepository = UserRepository();

  final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> errorMessageNotifier = ValueNotifier<String>("");
  final ValueNotifier<List<ReservationProfileDto>> reservations = ValueNotifier<List<ReservationProfileDto>>([]);


  User? get user => userNotifier.value;
  String? get errorMessage => errorMessageNotifier.value;

  /// Charger le profil utilisateur
  /// @return Future<void>
  /// @throws Exception si une erreur se produit lors du chargement
  Future<void> loadProfile() async {
    isLoadingNotifier.value = true;
    errorMessageNotifier.value = "";

    try {
      final loadedUser = await _userRepository.getProfile();
      final reservationList = await _userRepository.getUserReservations(userId : loadedUser!.id);
      userNotifier.value = loadedUser;
      reservations.value = reservationList;
      isLoadingNotifier.value = false;
    } catch (e) {
      errorMessageNotifier.value = e.toString();
      isLoadingNotifier.value = false;
    }
  }

//   isLoading
//   ? null
//       : () async {
//   final success =
//       await _profileViewModel.updateProfile(
//   name: nameController.text.trim(),
//   phone: phoneController.text.trim().isEmpty
//   ? null
//       : phoneController.text.trim(),
//   );
//
//   if (success && mounted) {
//   nameController.dispose();
//   phoneController.dispose();
//   Navigator.pop(sheetContext);
//   showCupertinoDialog(
//   context: context,
//   builder: (context) =>
//   CupertinoAlertDialog(
//   title: const Text('Succès'),
//   content: const Text(
//   'Profil mis à jour avec succès'),
//   actions: [
//   CupertinoDialogAction(
//   child: const Text('OK'),
//   onPressed: () =>
//   Navigator.pop(context),
//   ),
//   ],
//   ),
//   );
//   }
// }


  void clearError() {
    errorMessageNotifier.value = "";
  }

  void clear() {
    userNotifier.value = null;
    errorMessageNotifier.value = "";
  }

  /// Dispose des notifiers
  /// @return void
  @override
  void dispose() {
    userNotifier.dispose();
    reservations.dispose();
  }
}