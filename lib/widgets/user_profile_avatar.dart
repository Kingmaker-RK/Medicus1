import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/doctor_profile_provider.dart';
import '../providers/patient_profile_provider.dart';
import '../constants/app_constants.dart';

class UserProfileAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const UserProfileAvatar({
    Key? key,
    this.radius = 20,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We need to listen to all relevant providers to update when any of them changes
    final userProvider = Provider.of<UserProvider>(context);
    final isDoctor = userProvider.currentUser?.role == AppConstants.roleDoctor;
    
    ImageProvider? backgroundImage;
    bool hasProfilePicture = false;

    if (isDoctor) {
      final doctorProvider = Provider.of<DoctorProfileProvider>(context);
      final profile = doctorProvider.profile;
      if (profile.profilePictureUrl != null && profile.profilePictureUrl!.isNotEmpty) {
        hasProfilePicture = true;
        if (profile.profilePictureUrl!.startsWith('http')) {
          backgroundImage = NetworkImage(profile.profilePictureUrl!);
        } else {
          backgroundImage = FileImage(File(profile.profilePictureUrl!));
        }
      }
    } else {
      final patientProvider = Provider.of<PatientProfileProvider>(context);
      final profile = patientProvider.profile;
      if (profile.profilePicturePath.isNotEmpty) {
        hasProfilePicture = true;
        if (profile.profilePicturePath.startsWith('http')) {
           backgroundImage = NetworkImage(profile.profilePicturePath);
        } else {
           backgroundImage = FileImage(File(profile.profilePicturePath));
        }
      }
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      backgroundImage: backgroundImage,
      child: !hasProfilePicture
          ? Icon(
              isDoctor ? Icons.local_hospital_rounded : Icons.person_rounded,
              size: radius * 1.2, // Scale icon relative to radius
              color: Colors.white,
            )
          : null,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    return avatar;
  }
}
