import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../doctor_service.dart';
import 'write_prescription_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class PatientQueueScreen extends StatefulWidget {
  const PatientQueueScreen({super.key});

  @override
  State<PatientQueueScreen> createState() =>
      _PatientQueueScreenState();
}

class _PatientQueueScreenState extends State<PatientQueueScreen> {
  final DoctorService _doctorService = DoctorService();
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _reloadQueue();
  }

  void _reloadQueue() {
    final String? doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (doctorId == null) {
      _appointmentsFuture = Future.value([]);
      return;
    }

    _appointmentsFuture = _doctorService.getTodayAppointments(doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Green Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.doctorPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Title
                Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Queue',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Today',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Session info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'Today Queue',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Patients',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _appointmentsFuture,
                            builder: (context, snapshot) {
                              final int count = snapshot.data?.length ?? 0;
                              return Text(
                                '$count Total',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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
                  Text('Active Queue', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _appointmentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        );
                      }

                      final all = snapshot.data ?? [];
                      final patients = all
                          .where((a) => (a['status'] ?? 'pending') == 'pending')
                          .toList();

                      if (patients.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'No patients in today queue.',
                            style: AppTextStyles.bodySmall,
                          ),
                        );
                      }

                      return Column(
                        children: patients.asMap().entries.map((entry) {
                          int index = entry.key;
                          final patient = entry.value;
                          return _patientCard(patient, index == 0);
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

  Widget _patientCard(Map<String, dynamic> patient, bool isFirst) {
    bool isInProgress = isFirst;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isInProgress
            ? Border.all(color: AppColors.doctorPrimary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Name + CHK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.patientLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.patientPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient['patientName'] ?? 'Patient',
                          style: AppTextStyles.label),
                      Text(
                        'Queue #${patient['tokenNumber'] ?? '-'}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.patientPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  patient['checkupId'] ?? 'CHK',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Time + Status
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 4),
              Text(
                'Assigned Time: ${patient['time'] ?? '--'}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(width: 8),
              if (isInProgress)
                Text(
                  'In Progress',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.doctorPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  'Waiting',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Buttons for first card
          if (isFirst) ...[
            // Write Prescription button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Get.to(
                    () => WritePrescriptionScreen(
                      appointmentId: patient['appointmentId'],
                      patientData: {
                        'patientId': patient['patientId'],
                        'doctorId': patient['doctorId'],
                        'doctorName': patient['doctorName'],
                        'name': patient['patientName'],
                      },
                    ),
                  );
                  setState(_reloadQueue);
                },
                icon: const Icon(Icons.description_outlined,
                    color: AppColors.white, size: 16),
                label: Text(
                  'Write Prescription',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Complete + Cancel buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _doctorService
                            .completeAppointment(patient['appointmentId']);
                        if (!mounted) return;
                        Get.snackbar(
                          'Success',
                          'Checkup completed',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        setState(_reloadQueue);
                      } catch (e) {
                        if (!mounted) return;
                        Get.snackbar(
                          'Error',
                          'Failed to complete checkup: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline,
                        color: AppColors.white, size: 16),
                    label: Text(
                      'Complete Checkup',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.doctorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await _doctorService
                        .cancelAppointment(patient['appointmentId']);
                    setState(_reloadQueue);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Cancel button for other cards
            GestureDetector(
              onTap: () async {
                await _doctorService.cancelAppointment(patient['appointmentId']);
                setState(_reloadQueue);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close,
                        color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Cancel Appointment',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}