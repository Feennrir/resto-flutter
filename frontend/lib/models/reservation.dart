class Reservation {
  final String id;
  final String userId;
  final String restaurantId;
  final DateTime reservationDate;
  final String reservationTime;
  final int partySize;
  final ReservationStatus status;
  final String specialRequests;

  Reservation({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.reservationDate,
    required this.reservationTime,
    required this.partySize,
    this.status = ReservationStatus.pending,
    this.specialRequests = '',
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      restaurantId: json['restaurant_id'].toString(),
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: json['reservation_time'],
      partySize: json['party_size'],
      status: ReservationStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => ReservationStatus.pending,
      ),
      specialRequests: json['special_requests'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'reservation_date': reservationDate.toIso8601String(),
      'reservation_time': reservationTime,
      'party_size': partySize,
      'status': status.name,
      'special_requests': specialRequests,
    };
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}