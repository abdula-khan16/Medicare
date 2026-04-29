import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../patient_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final PatientService _patientService = PatientService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> upcomingAppointments = [];
  List<Map<String, dynamic>> pastAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => isLoading = true);
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return;

      List<Map<String, dynamic>> all = await _patientService.getPatientAppointments(uid);
      
      if (mounted) {
        setState(() {
          upcomingAppointments = all.where((a) => a['status'] == 'pending').toList();
          pastAppointments = all.where((a) => a['status'] == 'completed' || a['status'] == 'cancelled').toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _cancelBooking(String appointmentId, String sessionId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _patientService.cancelAppointment(appointmentId, sessionId);
      Get.back();
      _loadAppointments();
      Get.snackbar('Success', 'Appointment cancelled', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to cancel: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              color: AppColors.patientPrimary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
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
                Text('My Appointments', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
              ],
            ),
          ),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upcoming Appointments', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        upcomingAppointments.isEmpty 
                          ? const Center(child: Text('No upcoming appointments'))
                          : Column(children: upcomingAppointments.map((a) => _upcomingCard(a)).toList()),

                        const SizedBox(height: 24),
                        Text('Past Appointments', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        pastAppointments.isEmpty 
                          ? const Center(child: Text('No past history'))
                          : Column(children: pastAppointments.map((a) => _pastCard(a)).toList()),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _upcomingCard(Map<String, dynamic> a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a['doctorName'] ?? 'Doctor', style: AppTextStyles.label),
                  Text(a['specialization'] ?? 'Specialist', style: AppTextStyles.bodySmall.copyWith(color: AppColors.patientPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.patientPrimary, borderRadius: BorderRadius.circular(20)),
                child: Text(a['checkupId'] ?? 'CHK-000', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.textGrey, size: 16),
              const SizedBox(width: 8),
              Text(a['date'] ?? '', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.doctorLight, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.doctorPrimary, size: 16),
                const SizedBox(width: 8),
                Text('Time: ${a['time']}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.doctorPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.patientLight, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.patientPrimary, size: 16),
                const SizedBox(width: 8),
                Text('Queue Position: #${a['tokenNumber']}', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _cancelBooking(a['id'], a['sessionId']),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text('Cancel Appointment', style: AppTextStyles.label.copyWith(color: Colors.red.shade700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pastCard(Map<String, dynamic> a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a['doctorName'] ?? 'Doctor', style: AppTextStyles.label),
                  Text(a['specialization'] ?? 'Specialist', style: AppTextStyles.bodySmall),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: Text(a['status'] ?? 'Completed', style: AppTextStyles.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.textGrey, size: 16),
              const SizedBox(width: 8),
              Text(a['date'] ?? '', style: AppTextStyles.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: AppColors.textGrey, size: 16),
              const SizedBox(width: 8),
              Text(a['time'] ?? '', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
