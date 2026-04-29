import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'my_appointment_screen.dart';
import 'patient_home_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String date;
  final String time;
  final String checkupNumber;
  final String queuePosition;

  const BookingConfirmedScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.date,
    required this.time,
    required this.checkupNumber,
    required this.queuePosition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Green Check Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.doctorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.doctorPrimary,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Booking Confirmed!',
              style: AppTextStyles.heading2,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Your appointment has been scheduled successfully',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Main Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Checkup Number
                  Text(
                    'Your Checkup Number',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.patientPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      checkupNumber,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Doctor Name
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctorName, style: AppTextStyles.label),
                        Text(
                          specialization,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.patientPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppColors.patientPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date', style: AppTextStyles.bodySmall),
                          Text(date, style: AppTextStyles.label),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Assigned Time
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.doctorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppColors.doctorPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Assigned Time',
                                style: AppTextStyles.bodySmall),
                            Text(
                              time,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.doctorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Queue Position
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.patientLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tag,
                          color: AppColors.patientPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Queue Position',
                                style: AppTextStyles.bodySmall),
                            Text(
                              '#' + queuePosition + ' in line',
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Session time
                  Text(
                    'Session: 09:00 AM - 01:00 PM',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Important Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Note',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please arrive 10-15 minutes before your assigned time. Your checkup number will be called when it\'s your turn.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // View My Appointments Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const MyAppointmentsScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'View My Appointments',
                  style: AppTextStyles.button,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Back to Home Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => const PatientHomeScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}