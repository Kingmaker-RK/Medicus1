import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_routes.dart';
import '../models/service_model.dart';

final List<ServiceModel> services = [
  ServiceModel(
    title: 'E-Receipt',
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
    icon: FontAwesomeIcons.tooth,
    color: Colors.teal,
    route: AppRoutes.dentist,
  ),
  ServiceModel(
    title: 'Dermo',
    description: 'Dermatologist treatment. Upload pictures, ask questions, get diagnosis and aftercare.',
    icon: FontAwesomeIcons.handDots,
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
  ServiceModel(
    title: 'Physiotherapy',
    description: 'Find physiotherapy centers for rehabilitation and physical therapy.',
    icon: FontAwesomeIcons.personWalking,
    color: Colors.indigo,
    route: AppRoutes.physiotherapy,
  ),
  ServiceModel(
    title: 'Chiropractic',
    description: 'Find chiropractors for spinal adjustments and pain relief.',
    icon: LucideIcons.alignCenter,
    color: Colors.deepOrange,
    route: AppRoutes.chiropractic,
  ),
  ServiceModel(
    title: 'ENT Specialist',
    description: 'Ear, Nose, and Throat specialists. Find doctors and upload reports.',
    icon: LucideIcons.ear,
    color: Colors.cyan,
    route: AppRoutes.ent,
  ),
  ServiceModel(
    title: 'Eye Care',
    description: 'Find ophthalmologists and eye clinics. Manage your vision health.',
    icon: LucideIcons.eye,
    color: Colors.blueGrey,
    route: AppRoutes.eyeCare,
  ),
  ServiceModel(
    title: 'Addiction Recovery',
    description: 'Find support and recovery centers for various addictions.',
    icon: LucideIcons.heartHandshake,
    color: Colors.greenAccent,
    route: AppRoutes.addictionRecovery,
  ),
  ServiceModel(
    title: 'HIV/STI Prevention',
    description: 'Learn about prevention, get resources, and find help.',
    icon: LucideIcons.shieldAlert,
    color: Colors.redAccent,
    route: AppRoutes.hivPrevention,
  ),
  ServiceModel(
    title: 'Pulmonology',
    description: 'Find lung specialists and clinics. Upload and manage your reports.',
    icon: FontAwesomeIcons.lungs,
    color: Colors.lightBlue,
    route: AppRoutes.pulmonology,
  ),
  ServiceModel(
    title: 'Podiatry',
    description: 'Find foot care specialists. Manage reports and appointments.',
    icon: LucideIcons.footprints,
    color: Colors.indigoAccent,
    route: AppRoutes.podiatry,
  ),
  ServiceModel(
    title: 'Fertility & Child Care',
    description: 'Comprehensive fertility, pregnancy, and child care tracking with AI support.',
    icon: LucideIcons.heartPulse,
    color: Colors.pinkAccent,
    route: AppRoutes.fertilityChildCare,
  ),
];
