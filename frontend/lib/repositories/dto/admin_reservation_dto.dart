class AdminReservationDTO {
  final int id;
  final int userId;
  final int restaurantId;
  final String reservationDate;
  final String reservationTime;
  final int partySize;
  final String status;
  final String? specialRequests;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String restaurantName;

  AdminReservationDTO({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.reservationDate,
    required this.reservationTime,
    required this.partySize,
    required this.status,
    this.specialRequests,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.restaurantName,
  });

  factory AdminReservationDTO.fromJson(Map<String, dynamic> json) {
    return AdminReservationDTO(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      reservationDate: json['reservation_date'],
      reservationTime: json['reservation_time'],
      partySize: json['party_size'],
      status: json['status'],
      specialRequests: json['special_requests'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      restaurantName: json['restaurant_name'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}
