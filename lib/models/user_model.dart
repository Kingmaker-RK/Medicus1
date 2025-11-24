class UserModel {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String role; // 'patient' or 'doctor'
  final String languageCode;
  final bool isGuest;

  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    required this.role,
    required this.languageCode,
    this.isGuest = false,
  });

  String get name => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.tryParse(json['dateOfBirth'] as String) 
          : null,
      gender: json['gender'] as String?,
      role: json['role'] as String? ?? 'patient',
      languageCode: json['languageCode'] as String? ?? 'en',
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'name': name, // Keep for backward compatibility if needed
      'role': role,
      'languageCode': languageCode,
      'isGuest': isGuest,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? role,
    String? languageCode,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      languageCode: languageCode ?? this.languageCode,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
