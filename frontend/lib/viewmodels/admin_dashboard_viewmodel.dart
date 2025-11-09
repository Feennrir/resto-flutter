import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/repositories/admin_repository.dart';
import 'package:restaurant_menu/repositories/dto/admin_profil_dto.dart';

class AdminDashboardViewModel {
  AdminRepository adminRepository = AdminRepository();

  ValueNotifier<int> pendingReservations = ValueNotifier<int>(0);
  ValueNotifier<int> todayReservations = ValueNotifier<int>(0);
  ValueNotifier<int> totalDishes = ValueNotifier<int>(0);
  ValueNotifier<int> availableDishes = ValueNotifier<int>(0);

  void initialize() async{
    AdminProfileDTO adminData = await adminRepository.getStats();
    totalDishes.value = adminData.totalDishes;
    availableDishes.value = adminData.availableDishes;
    pendingReservations.value = adminData.pendingReservations;
    todayReservations.value = adminData.todayReservations;
  }
}