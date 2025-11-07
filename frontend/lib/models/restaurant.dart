class Restaurant {
  final String id;
  final String name;
  final String address;
  final String cuisine;
  final double rating;
  final int maxCapacity;
  final String? phoneNumber;
  final int serviceDurationMinutes;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.cuisine,
    required this.rating,
    required this.maxCapacity,
    this.phoneNumber,
    required this.serviceDurationMinutes,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      cuisine: json['cuisine'],
      rating: double.parse(json['rating'].toString()),
      maxCapacity: json['max_capacity'],
      phoneNumber: json['phone_number'],
      serviceDurationMinutes: json['service_duration_minutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'cuisine': cuisine,
      'rating': rating,
      'max_capacity': maxCapacity,
      'phone_number': phoneNumber,
      'service_duration_minutes': serviceDurationMinutes,
    };
  }
}