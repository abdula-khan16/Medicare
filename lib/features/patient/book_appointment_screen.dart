import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../patient_service.dart';
import 'booking_confirmed_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final Map<String, dynamic> sessionData;

  const BookAppointmentScreen({
    super.key,
    required this.doctorData,
    required this.sessionData,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final PatientService _patientService = PatientService();
  bool isLoading = false;

  Future<void> confirmBooking() async {
    setState(() => isLoading = true);

    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw "User not logged in";

      String dateStr = "";
      if (widget.sessionData['date'] is Timestamp) {
        dateStr = DateFormat('MMM dd, yyyy').format((widget.sessionData['date'] as Timestamp).toDate());
      }

      // Call Service
      var result = await _patientService.bookAppointment(
        patientId: uid,
        doctorId: widget.doctorData['uid'],
        sessionId: widget.sessionData['id'],
        date: dateStr,
        time: '${widget.sessionData['startTime']} - ${widget.sessionData['endTime']}',
      );

      // Navigate to success
      Get.off(() => BookingConfirmedScreen(
        doctorName: widget.doctorData['name'] ?? 'Doctor',
        specialization: widget.doctorData['specialization'] ?? 'Specialist',
        date: dateStr,
        time: '${widget.sessionData['startTime']} - ${widget.sessionData['endTime']}',
        checkupNumber: result['checkupId'],
        queuePosition: result['tokenNumber'],
      ));
    } catch (e) {
      Get.snackbar('Error', 'Booking failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = widget.sessionData['totalSlots'] ?? 0;
    int booked = widget.sessionData['bookedSlots'] ?? 0;
    int available = total - booked;
    String gap = '${widget.sessionData['gapBetweenPatients']} minutes';
    
    String dateStr = "";
    if (widget.sessionData['date'] is Timestamp) {
      dateStr = DateFormat('MMM dd, yyyy').format((widget.sessionData['date'] as Timestamp).toDate());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.patientPrimary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Book Appointment', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: const BoxDecoration(color: AppColors.patientLight, shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: AppColors.patientPrimary, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.doctorData['name'] ?? 'Doctor', style: AppTextStyles.label),
                                Text(widget.doctorData['specialization'] ?? 'Specialist', style: AppTextStyles.bodySmall.copyWith(color: AppColors.patientPrimary)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _infoRow(Icons.calendar_month, AppColors.patientPrimary, AppColors.patientLight, 'Date', dateStr),
                        const SizedBox(height: 12),
                        _infoRow(Icons.access_time, AppColors.doctorPrimary, AppColors.doctorLight, 'Session Time', '${widget.sessionData['startTime']} - ${widget.sessionData['endTime']}'),
                        const SizedBox(height: 12),
                        _infoRow(Icons.people_outline, Colors.purple, Colors.purple.shade50, 'Gap Between Patients', gap),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.patientLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.patientPrimary.withOpacity(0.3))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.patientPrimary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Token-Based System', style: AppTextStyles.label.copyWith(color: AppColors.patientPrimary)),
                              const SizedBox(height: 4),
                              Text('Your time slot will be assigned automatically based on your queue position.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.patientPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session Details', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        _detailRow('Total Slots', '$total patients'),
                        const Divider(height: 16),
                        _detailRow('Already Booked', '$booked patients'),
                        const Divider(height: 16),
                        _detailRow('Available', '$available slots', valueColor: AppColors.doctorPrimary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading || available <= 0 ? null : confirmBooking,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.patientPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(available > 0 ? 'Confirm Booking' : 'Fully Booked', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, Color iconColor, Color iconBgColor, String label, String value) {
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTextStyles.bodySmall), Text(value, style: AppTextStyles.label)]),
      ],
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.bodySmall), Text(value, style: AppTextStyles.label.copyWith(color: valueColor ?? AppColors.textDark))]);
  }
}
