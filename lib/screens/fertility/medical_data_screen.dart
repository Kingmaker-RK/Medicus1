import 'package:flutter/material.dart';

class MedicalDataScreen extends StatelessWidget {
  const MedicalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Data Integration')),
      body: const Center(child: Text('Medical Data Content Here')),
    );
  }
}
