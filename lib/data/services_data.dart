import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_routes.dart';
import '../models/service_model.dart';

final List<ServiceModel> services = [
  ServiceModel(
    title: 'E-Rezept',
    description: 'Buy medication as per prescription. Upload prescription and insurance card photos.',
    icon: LucideIcons.pill,
    color: Colors.blue,
    route: AppRoutes.eRezept,
  ),
  ServiceModel(
    title: 'Pregnancy Tracker',
    description: 'Track your pregnancy journey with weekly updates and health tips.',
    icon: LucideIcons.userPlus,
    color: Colors.pink,
    route: AppRoutes.pregnancyTracker,
  ),
  ServiceModel(
    title: 'Blood Donation',
    description: 'Find blood donation centers and schedule appointments.',
    icon: LucideIcons.droplet,
    color: Colors.red,
    route: AppRoutes.bloodDonation,
  ),
  ServiceModel(
    title: 'Dentist',
    description: 'Find dentists in your area by name, location, or pincode.',
    icon: LucideIcons.smile,
    color: Colors.teal,
    route: AppRoutes.dentist,
  ),
  ServiceModel(
    title: 'Dermo',
    description: 'Dermatologist treatment. Upload pictures, ask questions, get diagnosis and aftercare.',
    icon: LucideIcons.scanFace,
    color: Colors.orange,
    route: AppRoutes.dermo,
  ),
  ServiceModel(
    title: 'Baby Tracker',
    description: 'Track your newborn\'s feeding, sleep, and growth.',
    icon: LucideIcons.baby,
    color: Colors.purple,
    route: AppRoutes.babyTracker,
  ),
  ServiceModel(
    title: 'Orthopedic',
    description: 'Orthopedic examination tools for doctors. Similar to Orthoexamine.',
    icon: LucideIcons.bone,
    color: Colors.brown,
    route: AppRoutes.orthopedic,
  ),
  ServiceModel(
    title: 'FitPhysic',
    description: 'Personal guide for successful rehab with training videos.',
    icon: LucideIcons.dumbbell,
    color: Colors.green,
    route: AppRoutes.fitphysic,
  ),
];
