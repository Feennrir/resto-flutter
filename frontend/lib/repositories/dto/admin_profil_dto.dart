class AdminProfileDTO {
  final int pendingReservations;
  final int todayReservations;
  final int totalDishes;
  final int availableDishes;

  AdminProfileDTO({
    required this.pendingReservations,
    required this.todayReservations,
    required this.totalDishes,
    required this.availableDishes,
  });

  factory AdminProfileDTO.fromJson(Map<String, dynamic> json) {
    return AdminProfileDTO(
      pendingReservations: json['pending_reservations'],
      todayReservations: json['today_reservations'],
      totalDishes: json['total_dishes'],
      availableDishes: json['available_dishes'],
    );
  }
}