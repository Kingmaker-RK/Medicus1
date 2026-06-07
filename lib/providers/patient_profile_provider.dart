import 'package:flutter/foundation.dart';
import '../models/patient_profile_model.dart';
import '../services/database_service.dart';

class PatientProfileProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  
  PatientProfileModel _profile = PatientProfileModel();
  bool _isLoading = false;
  String? _userId;

  PatientProfileProvider({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  PatientProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  // Update provider with current user ID
  Future<void> updateUser(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;
    
    if (_userId != null) {
      await _loadProfile();
    } else {
      _profile = PatientProfileModel();
      notifyListeners();
    }
  }

  // Initialize profile - Deprecated, use updateUser
  Future<void> initialize() async {
    // No-op: Initialization is handled by updateUser via ProxyProvider
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _databaseService.getPatientProfile(_userId!);
      if (profile != null) {
        _profile = profile;
      } else {
        _profile = PatientProfileModel();
      }
    } catch (e) {
      print('Error loading patient profile: $e');
      _profile = PatientProfileModel();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save profile to database
  Future<void> _saveProfile() async {
    if (_userId == null) return;

    try {
      await _databaseService.savePatientProfile(_userId!, _profile);
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  // Update personal information
  Future<void> updatePersonalInfo({
    String? firstName,
    String? secondName,
    String? insuranceNumber,
    String? insuranceProvider,
    String? profilePicturePath,
  }) async {
    _profile = _profile.copyWith(
      firstName: firstName,
      secondName: secondName,
      insuranceNumber: insuranceNumber,
      insuranceProvider: insuranceProvider,
      profilePicturePath: profilePicturePath,
    );
    await _saveProfile();
    notifyListeners();
  }

  // Update profile picture
  Future<void> updateProfilePicture(String path) async {
    _profile = _profile.copyWith(profilePicturePath: path);
    await _saveProfile();
    notifyListeners();
  }

  // Add certificate
  Future<void> addCertificate(Certificate certificate) async {
    final updatedCertificates = List<Certificate>.from(_profile.certificates)
      ..add(certificate);
    _profile = _profile.copyWith(certificates: updatedCertificates);
    await _saveProfile();
    notifyListeners();
  }

  // Remove certificate
  Future<void> removeCertificate(String certificateId) async {
    final updatedCertificates = _profile.certificates
        .where((cert) => cert.id != certificateId)
        .toList();
    _profile = _profile.copyWith(certificates: updatedCertificates);
    await _saveProfile();
    notifyListeners();
  }

  // Submit sick note
  Future<void> submitSickNote(SickNote sickNote) async {
    final updatedSickNotes = List<SickNote>.from(_profile.sickNotes)
      ..add(sickNote);
    _profile = _profile.copyWith(sickNotes: updatedSickNotes);
    await _saveProfile();
    notifyListeners();
  }

  // Update sick note status
  Future<void> updateSickNoteStatus(String sickNoteId, String status) async {
    final updatedSickNotes = _profile.sickNotes.map((note) {
      if (note.id == sickNoteId) {
        return SickNote(
          id: note.id,
          startDate: note.startDate,
          endDate: note.endDate,
          diagnosis: note.diagnosis,
          status: status,
          fileUrl: note.fileUrl,
        );
      }
      return note;
    }).toList();
    _profile = _profile.copyWith(sickNotes: updatedSickNotes);
    await _saveProfile();
    notifyListeners();
  }

  // Add reimbursement
  Future<void> addReimbursement(Reimbursement reimbursement) async {
    final updatedReimbursements = List<Reimbursement>.from(
      _profile.reimbursements,
    )..add(reimbursement);
    _profile = _profile.copyWith(reimbursements: updatedReimbursements);
    await _saveProfile();
    notifyListeners();
  }

  // Update reimbursement status
  Future<void> updateReimbursementStatus(
    String reimbursementId,
    String status,
  ) async {
    final updatedReimbursements = _profile.reimbursements.map((reimb) {
      if (reimb.id == reimbursementId) {
        return Reimbursement(
          id: reimb.id,
          date: reimb.date,
          amount: reimb.amount,
          description: reimb.description,
          status: status,
          receiptUrl: reimb.receiptUrl,
        );
      }
      return reimb;
    }).toList();
    _profile = _profile.copyWith(reimbursements: updatedReimbursements);
    await _saveProfile();
    notifyListeners();
  }

  // Add mailbox message
  Future<void> addMailboxMessage(MailboxMessage message) async {
    final updatedMailbox = List<MailboxMessage>.from(_profile.mailbox)
      ..add(message);
    _profile = _profile.copyWith(mailbox: updatedMailbox);
    await _saveProfile();
    notifyListeners();
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final updatedMailbox = _profile.mailbox.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isRead: true);
      }
      return msg;
    }).toList();
    _profile = _profile.copyWith(mailbox: updatedMailbox);
    await _saveProfile();
    notifyListeners();
  }

  // Get unread message count
  int get unreadMessageCount {
    return _profile.mailbox.where((msg) => !msg.isRead).length;
  }
}
