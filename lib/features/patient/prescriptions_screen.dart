import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../patient_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() =>
      _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final PatientService _patientService = PatientService();
  late Future<List<Map<String, dynamic>>> _prescriptionsFuture;

  final Color purpleColor = const Color(0xFF7C3AED);
  final Color purpleLightColor = const Color(0xFFF5F3FF);

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _prescriptionsFuture = uid == null
        ? Future.value([])
        : _patientService.getPatientPrescriptions(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Purple Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              color: purpleColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'My Prescriptions',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text('My Prescriptions', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _prescriptionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final prescriptions = snapshot.data ?? [];
                      if (prescriptions.isEmpty) {
                        return Text(
                          'No prescriptions found yet.',
                          style: AppTextStyles.bodySmall,
                        );
                      }

                      return Column(
                        children: prescriptions.map((prescription) {
                          final meds =
                              (prescription['medicines'] as List<dynamic>? ?? [])
                                  .map((e) =>
                                      Map<String, dynamic>.from(e as Map))
                                  .toList();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _prescriptionCard(
                              doctorName:
                                  prescription['doctorName'] ?? 'Doctor',
                              date: _formatDate(prescription['date']),
                              medications: meds,
                              doctorNotes: prescription['notes'] ?? '',
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Active Prescription Card
  Widget _prescriptionCard({
    required String doctorName,
    required String date,
    required List<Map<String, dynamic>> medications,
    required String doctorNotes,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info + download
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: purpleLightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: purpleColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName, style: AppTextStyles.label),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.download_outlined,
                color: AppColors.textGrey,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 4),
              Text(date, style: AppTextStyles.bodySmall),
            ],
          ),

          const SizedBox(height: 12),

          // Medications title
          Row(
            children: [
              Icon(Icons.edit_outlined,
                  color: AppColors.textGrey, size: 16),
              const SizedBox(width: 8),
              Text('Medications', style: AppTextStyles.label),
            ],
          ),

          const SizedBox(height: 8),

          // Medications list
          Column(
            children: medications.map((med) {
              return _medicationTile(med);
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Doctor Notes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.patientLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor\'s Notes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.patientPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctorNotes,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.patientPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Medication Tile
  Widget _medicationTile(Map<String, dynamic> med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(med['name']?.toString() ?? '-', style: AppTextStyles.label),
            ],
          ),
          Text(
            med['dosage']?.toString() ?? '-',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.patientPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(med['instructions']?.toString() ?? '',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return '-';
  }
}