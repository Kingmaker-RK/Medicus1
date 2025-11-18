class UserModel {
  final String? id;
  final String? email;
  final String? name;
  final String role; // 'patient' or 'doctor'
  final String languageCode;
  final bool isGuest;

  UserModel({
    this.id,
    this.email,
    this.name,
    required this.role,
    required this.languageCode,
    this.isGuest = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'patient',
      languageCode: json['languageCode'] as String? ?? 'en',
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'languageCode': languageCode,
      'isGuest': isGuest,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? languageCode,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      languageCode: languageCode ?? this.languageCode,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
