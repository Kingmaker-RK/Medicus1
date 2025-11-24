class DoctorProfileModel {
  final String name;
  final String speciality;
  final String highestQualification;
  final int yearsOfExperience;
  final String clinicAddress;
  final String approbationCertificate;
  final String idNumber;
  final String personnelNumber;
  final String? profilePictureUrl;
  final List<String> languages;

  DoctorProfileModel({
    this.name = '',
    this.speciality = '',
    this.highestQualification = '',
    this.yearsOfExperience = 0,
    this.clinicAddress = '',
    this.approbationCertificate = '',
    this.idNumber = '',
    this.personnelNumber = '',
    this.profilePictureUrl,
    this.languages = const [],
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      name: json['name'] as String? ?? '',
      speciality: json['speciality'] as String? ?? '',
      highestQualification: json['highestQualification'] as String? ?? '',
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
      clinicAddress: json['clinicAddress'] as String? ?? '',
      approbationCertificate: json['approbationCertificate'] as String? ?? '',
      idNumber: json['idNumber'] as String? ?? '',
      personnelNumber: json['personnelNumber'] as String? ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'speciality': speciality,
      'highestQualification': highestQualification,
      'yearsOfExperience': yearsOfExperience,
      'clinicAddress': clinicAddress,
      'approbationCertificate': approbationCertificate,
      'idNumber': idNumber,
      'personnelNumber': personnelNumber,
      'profilePictureUrl': profilePictureUrl,
      'languages': languages,
    };
  }

  DoctorProfileModel copyWith({
    String? name,
    String? speciality,
    String? highestQualification,
    int? yearsOfExperience,
    String? clinicAddress,
    String? approbationCertificate,
    String? idNumber,
    String? personnelNumber,
    String? profilePictureUrl,
    List<String>? languages,
  }) {
    return DoctorProfileModel(
      name: name ?? this.name,
      speciality: speciality ?? this.speciality,
      highestQualification: highestQualification ?? this.highestQualification,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      approbationCertificate:
          approbationCertificate ?? this.approbationCertificate,
      idNumber: idNumber ?? this.idNumber,
      personnelNumber: personnelNumber ?? this.personnelNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      languages: languages ?? this.languages,
    );
  }

  // Check if profile is complete (all required fields filled)
  bool get isComplete {
    return name.isNotEmpty &&
        speciality.isNotEmpty &&
        highestQualification.isNotEmpty &&
        yearsOfExperience > 0 &&
        clinicAddress.isNotEmpty &&
        approbationCertificate.isNotEmpty &&
        idNumber.isNotEmpty &&
        personnelNumber.isNotEmpty;
  }

  // Get list of missing required fields
  List<String> get missingFields {
    final missing = <String>[];
    if (name.isEmpty) missing.add('Name');
    if (speciality.isEmpty) missing.add('Speciality');
    if (highestQualification.isEmpty) missing.add('Highest Qualification');
    if (yearsOfExperience <= 0) missing.add('Years of Experience');
    if (clinicAddress.isEmpty) missing.add('Clinic Address');
    if (approbationCertificate.isEmpty) missing.add('Approbation Certificate');
    if (idNumber.isEmpty) missing.add('ID Number');
    if (personnelNumber.isEmpty) missing.add('Personnel Number');
    return missing;
  }
}
