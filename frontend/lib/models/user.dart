class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  /// Création d'une instance de User à partir d'un JSON
  /// @param json Map<String, dynamic>
  /// @return User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : null,
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Récupère l'année d'adhésion de l'utilisateur
  /// @return String
  String getJoinYear() {
    if (createdAt == null) return '';
    return createdAt!.year.toString();
  }

  /// Crée une copie de l'utilisateur avec des champs modifiés
  /// @param id int?
  /// @param name String?
  /// @param email String?
  /// @param phone String?
  /// @param createdAt DateTime?
  /// @param updatedAt DateTime?
  /// @return User
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}