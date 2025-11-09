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
      pendingReservations: json['pendingReservations'] ?? 0,
      todayReservations: json['todayReservations'] ?? 0,
      totalDishes: json['totalDishes'] ?? 0,
      availableDishes: json['availableDishes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingReservations': pendingReservations,
      'todayReservations': todayReservations,
      'totalDishes': totalDishes,
      'availableDishes': availableDishes,
    };
  }
}