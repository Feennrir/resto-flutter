class ReservationProfileDto {

  final String date;
  final String time;
  final int guests;
  final String status;
  final bool isUpcoming;

  ReservationProfileDto({
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
    required this.isUpcoming,
  });

  factory ReservationProfileDto.fromJson(Map<String, dynamic> json) {
    return ReservationProfileDto(
      date: json['date'],
      time: json['time'],
      guests: json['guests'],
      status: json['status'],
      isUpcoming: json['isUpcoming'],
    );
  }
}