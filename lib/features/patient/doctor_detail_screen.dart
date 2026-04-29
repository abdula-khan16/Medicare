import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../doctor_service.dart';
import 'book_appointment_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorDetailScreen({
    super.key,
    required this.doctorData,
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  List<Map<String, dynamic>> sessions = [];
  bool isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      String? doctorId = widget.doctorData['uid'];
      if (doctorId != null) {
        var fetchedSessions = await _doctorService.getDoctorSessions(doctorId);
        if (mounted) {
          setState(() {
            sessions = fetchedSessions;
            isLoadingSessions = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingSessions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.doctorData['name'] ?? 'Doctor';
    final String specialization = widget.doctorData['specialization'] ?? 'Specialist';
    final String rating = (widget.doctorData['rating'] ?? 0.0).toString();
    final String location = widget.doctorData['location'] ?? 'Not specified';
    final String experience = widget.doctorData['experience']?.toString() ?? '0';
    final String about = widget.doctorData['about'] ?? 'No information provided.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
              decoration: const BoxDecoration(
                color: AppColors.patientPrimary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: const BoxDecoration(color: AppColors.patientLight, shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: AppColors.patientPrimary, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                            Text(specialization, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text('$rating Rating', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(Icons.work_outline, 'Experience', '$experience years'),
                        _infoItem(Icons.location_on_outlined, 'Location', location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About Me', style: AppTextStyles.heading3),
                        const SizedBox(height: 8),
                        Text(about, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Sessions', style: AppTextStyles.heading3),
                        const SizedBox(height: 12),
                        isLoadingSessions
                            ? const Center(child: CircularProgressIndicator())
                            : sessions.isEmpty
                                ? const Center(child: Text('No available sessions'))
                                : Column(
                                    children: sessions.map((s) => _sessionCard(context, s)).toList(),
                                  ),
                      ],
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

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: AppColors.patientLight, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.patientPrimary, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                Text(value, style: AppTextStyles.label, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(BuildContext context, Map<String, dynamic> session) {
    String dateStr = "";
    if (session['date'] is Timestamp) {
      dateStr = DateFormat('MMM dd, yyyy').format((session['date'] as Timestamp).toDate());
    }
    
    int total = session['totalSlots'] ?? 0;
    int booked = session['bookedSlots'] ?? 0;
    int available = total - booked;

    return GestureDetector(
      onTap: available > 0 ? () {
        Get.to(() => BookAppointmentScreen(
              doctorData: widget.doctorData,
              sessionData: session,
        ));
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: available > 0 ? Colors.grey.shade200 : Colors.red.shade100),
          borderRadius: BorderRadius.circular(12),
          color: available > 0 ? Colors.white : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.patientPrimary, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: AppTextStyles.label),
                    Text('${session['gapBetweenPatients']} min/patient', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${session['startTime']} - ${session['endTime']}', style: AppTextStyles.bodySmall),
                Text(
                  available > 0 ? '$available slots left' : 'Full',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: available > 0 ? AppColors.doctorPrimary : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
