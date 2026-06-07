import 'package:flutter/material.dart';

class ServiceModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  ServiceModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
