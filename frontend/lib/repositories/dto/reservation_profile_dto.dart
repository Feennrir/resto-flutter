class ReservationProfileDto {

  final int id;
  final String date;
  final String time;
  final int guests;
  final String status;
  final bool isUpcoming;

  ReservationProfileDto({
    required this.id,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
    required this.isUpcoming,
  });

  factory ReservationProfileDto.fromJson(Map<String, dynamic> json) {
    return ReservationProfileDto(
      id: json['id'],
      date: json['date'],
      time: json['time'],
      guests: json['guests'],
      status: json['status'],
      isUpcoming: json['isUpcoming'],
    );
  }
}