import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfileModel _profile = UserProfileModel();
  bool _isLoading = false;

  UserProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  // Initialize profile from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');

      if (profileJson != null) {
        _profile = UserProfileModel.fromJson(
          json.decode(profileJson) as Map<String, dynamic>,
        );
      } else {
        // Initialize with demo data
        _profile = _getDemoProfile();
      }
    } catch (e) {
      print('Error initializing profile: $e');
      _profile = _getDemoProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save profile to storage
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(_profile.toJson()));
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
  }) async {
    _profile = _profile.copyWith(
      firstName: firstName,
      secondName: secondName,
      insuranceNumber: insuranceNumber,
      insuranceProvider: insuranceProvider,
    );
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
    final updatedReimbursements = List<Reimbursement>.from(_profile.reimbursements)
      ..add(reimbursement);
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

  // Demo profile data
  UserProfileModel _getDemoProfile() {
    return UserProfileModel(
      firstName: 'John',
      secondName: 'Doe',
      insuranceNumber: 'INS123456789',
      insuranceProvider: 'Health Insurance Corp',
      certificates: [
        Certificate(
          id: '1',
          name: 'Vaccination Certificate',
          issueDate: '2024-01-15',
          expiryDate: '2025-01-15',
        ),
        Certificate(
          id: '2',
          name: 'Blood Test Results',
          issueDate: '2024-02-20',
        ),
      ],
      sickNotes: [
        SickNote(
          id: '1',
          startDate: '2024-03-01',
          endDate: '2024-03-05',
          diagnosis: 'Common Cold',
          status: 'approved',
        ),
      ],
      reimbursements: [
        Reimbursement(
          id: '1',
          date: '2024-02-15',
          amount: '€50.00',
          description: 'Prescription Medication',
          status: 'approved',
        ),
        Reimbursement(
          id: '2',
          date: '2024-03-10',
          amount: '€120.00',
          description: 'Dental Treatment',
          status: 'pending',
        ),
      ],
      mailbox: [
        MailboxMessage(
          id: '1',
          subject: 'Your test results are ready',
          sender: 'Dr. Smith',
          date: '2024-03-15',
          message: 'Your recent blood test results are now available. All values are within normal range.',
          isRead: false,
        ),
        MailboxMessage(
          id: '2',
          subject: 'Appointment Reminder',
          sender: 'Medicus Clinic',
          date: '2024-03-14',
          message: 'This is a reminder about your upcoming appointment on March 20th at 10:00 AM.',
          isRead: true,
        ),
      ],
    );
  }
}
