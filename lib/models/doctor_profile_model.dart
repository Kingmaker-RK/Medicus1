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
    );
  }
}
