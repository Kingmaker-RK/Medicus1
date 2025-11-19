class PatientProfileModel {
  final String firstName;
  final String secondName;
  final String insuranceNumber;
  final String insuranceProvider;
  final String profilePicturePath;
  final List<Certificate> certificates;
  final List<SickNote> sickNotes;
  final List<Reimbursement> reimbursements;
  final List<MailboxMessage> mailbox;

  PatientProfileModel({
    this.firstName = '',
    this.secondName = '',
    this.insuranceNumber = '',
    this.insuranceProvider = '',
    this.profilePicturePath = '',
    this.certificates = const [],
    this.sickNotes = const [],
    this.reimbursements = const [],
    this.mailbox = const [],
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      firstName: json['firstName'] as String? ?? '',
      secondName: json['secondName'] as String? ?? '',
      insuranceNumber: json['insuranceNumber'] as String? ?? '',
      insuranceProvider: json['insuranceProvider'] as String? ?? '',
      profilePicturePath: json['profilePicturePath'] as String? ?? '',
      certificates:
          (json['certificates'] as List<dynamic>?)
              ?.map((e) => Certificate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sickNotes:
          (json['sickNotes'] as List<dynamic>?)
              ?.map((e) => SickNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reimbursements:
          (json['reimbursements'] as List<dynamic>?)
              ?.map((e) => Reimbursement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mailbox:
          (json['mailbox'] as List<dynamic>?)
              ?.map((e) => MailboxMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'secondName': secondName,
      'insuranceNumber': insuranceNumber,
      'insuranceProvider': insuranceProvider,
      'profilePicturePath': profilePicturePath,
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'sickNotes': sickNotes.map((e) => e.toJson()).toList(),
      'reimbursements': reimbursements.map((e) => e.toJson()).toList(),
      'mailbox': mailbox.map((e) => e.toJson()).toList(),
    };
  }

  PatientProfileModel copyWith({
    String? firstName,
    String? secondName,
    String? insuranceNumber,
    String? insuranceProvider,
    String? profilePicturePath,
    List<Certificate>? certificates,
    List<SickNote>? sickNotes,
    List<Reimbursement>? reimbursements,
    List<MailboxMessage>? mailbox,
  }) {
    return PatientProfileModel(
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      certificates: certificates ?? this.certificates,
      sickNotes: sickNotes ?? this.sickNotes,
      reimbursements: reimbursements ?? this.reimbursements,
      mailbox: mailbox ?? this.mailbox,
    );
  }

  // Check if profile is complete (all required fields filled)
  bool get isComplete {
    return firstName.isNotEmpty &&
        secondName.isNotEmpty &&
        insuranceNumber.isNotEmpty &&
        insuranceProvider.isNotEmpty;
  }

  // Get list of missing required fields
  List<String> get missingFields {
    final missing = <String>[];
    if (firstName.isEmpty) missing.add('First Name');
    if (secondName.isEmpty) missing.add('Second Name');
    if (insuranceNumber.isEmpty) missing.add('Insurance Number');
    if (insuranceProvider.isEmpty) missing.add('Insurance Provider');
    return missing;
  }
}

class Certificate {
  final String id;
  final String name;
  final String issueDate;
  final String expiryDate;
  final String fileUrl;

  Certificate({
    required this.id,
    required this.name,
    required this.issueDate,
    this.expiryDate = '',
    this.fileUrl = '',
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      name: json['name'] as String,
      issueDate: json['issueDate'] as String,
      expiryDate: json['expiryDate'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'fileUrl': fileUrl,
    };
  }
}

class SickNote {
  final String id;
  final String startDate;
  final String endDate;
  final String diagnosis;
  final String status;
  final String fileUrl;

  SickNote({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.diagnosis = '',
    this.status = 'pending',
    this.fileUrl = '',
  });

  factory SickNote.fromJson(Map<String, dynamic> json) {
    return SickNote(
      id: json['id'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      diagnosis: json['diagnosis'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      fileUrl: json['fileUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'diagnosis': diagnosis,
      'status': status,
      'fileUrl': fileUrl,
    };
  }
}

class Reimbursement {
  final String id;
  final String date;
  final String amount;
  final String description;
  final String status;
  final String receiptUrl;

  Reimbursement({
    required this.id,
    required this.date,
    required this.amount,
    this.description = '',
    this.status = 'pending',
    this.receiptUrl = '',
  });

  factory Reimbursement.fromJson(Map<String, dynamic> json) {
    return Reimbursement(
      id: json['id'] as String,
      date: json['date'] as String,
      amount: json['amount'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      receiptUrl: json['receiptUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'description': description,
      'status': status,
      'receiptUrl': receiptUrl,
    };
  }
}

class MailboxMessage {
  final String id;
  final String subject;
  final String sender;
  final String date;
  final String message;
  final bool isRead;

  MailboxMessage({
    required this.id,
    required this.subject,
    required this.sender,
    required this.date,
    required this.message,
    this.isRead = false,
  });

  factory MailboxMessage.fromJson(Map<String, dynamic> json) {
    return MailboxMessage(
      id: json['id'] as String,
      subject: json['subject'] as String,
      sender: json['sender'] as String,
      date: json['date'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'sender': sender,
      'date': date,
      'message': message,
      'isRead': isRead,
    };
  }

  MailboxMessage copyWith({bool? isRead}) {
    return MailboxMessage(
      id: id,
      subject: subject,
      sender: sender,
      date: date,
      message: message,
      isRead: isRead ?? this.isRead,
    );
  }
}
