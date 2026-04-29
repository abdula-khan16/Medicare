import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicaare/core/constants/app_strings.dart';
import 'package:medicaare/core/constants/app_text_styles.dart';
import 'package:medicaare/features/patient/my_appointment_screen.dart';
import 'package:medicaare/features/patient/patient_profile_screen.dart';
import 'package:medicaare/features/patient/prescriptions_screen.dart';
import 'package:medicaare/patient_service.dart';

import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'find_doctor_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final PatientService _patientService = PatientService();
  String patientName = "Loading...";
  bool isLoading = true;
  int currentIndex = 0;
  Map<String, dynamic>? upcomingAppointment;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Load Profile
        var profile = await _patientService.getPatientData(uid);
        
        // Load Next Appointment for Home Card
        var appointments = await _patientService.getPatientAppointments(uid);
        var pending = appointments.where((a) => a['status'] == 'pending').toList();
        
        if (mounted) {
          setState(() {
            patientName = profile?['name'] ?? "Patient";
            if (pending.isNotEmpty) {
              upcomingAppointment = pending.first;
            } else {
              upcomingAppointment = null;
            }
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 0) _loadAllData(); // Refresh home when clicking home
        },
        selectedItemColor: AppColors.patientPrimary,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          _homeContent(),
          const MyAppointmentsScreen(),
          const PatientProfileScreen(),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return SingleChildScrollView(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.welcomeBack, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                        Text(patientName, style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const LoginScreen());
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.logout, color: AppColors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textGrey),
                      const SizedBox(width: 8),
                      const Expanded(child: TextField(decoration: InputDecoration(hintText: AppStrings.searchDoctors, border: InputBorder.none))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16, mainAxisSpacing: 16,
              children: [
                _actionCard(icon: Icons.medical_services_outlined, iconColor: AppColors.patientPrimary, iconBgColor: AppColors.patientLight, title: 'Find Doctors', subtitle: 'Search specialists', onTap: () => Get.to(() => const FindDoctorScreen())?.then((_) => _loadAllData())),
                _actionCard(icon: Icons.calendar_month_outlined, iconColor: AppColors.doctorPrimary, iconBgColor: AppColors.doctorLight, title: 'Appointments', subtitle: 'View schedule', onTap: () => setState(() => currentIndex = 1)),
                _actionCard(icon: Icons.description_outlined, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50, title: 'Prescriptions', subtitle: 'Medical records', onTap: () => Get.to(() => const PrescriptionsScreen())),
                _actionCard(icon: Icons.person_outline, iconColor: Colors.orange, iconBgColor: Colors.orange.shade50, title: 'Profile', subtitle: 'Settings & info', onTap: () => setState(() => currentIndex = 2)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Upcoming Appointment Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: upcomingAppointment == null 
              ? Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text('No upcoming appointments', style: AppTextStyles.bodySmall)),
                )
              : Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.doctorPrimary, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Upcoming Appointment', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text(upcomingAppointment!['checkupId'] ?? 'CHK', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(upcomingAppointment!['doctorName'] ?? 'Doctor', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                      Text(upcomingAppointment!['specialization'] ?? 'Specialist', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                      const Divider(color: Colors.white38, height: 24),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(upcomingAppointment!['date'] ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, color: AppColors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(upcomingAppointment!['time'] ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _actionCard({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 28)),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
