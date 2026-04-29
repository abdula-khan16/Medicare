import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Added missing import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicaare/features/doctor/my_patients_screen.dart';
import 'package:medicaare/features/doctor/patient_queue_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../doctor_service.dart';
import '../auth/login_screen.dart';
import 'create_session_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {

  final DoctorService _doctorService = DoctorService();

  String doctorName = 'Loading...';
  String specialization = '';
  String todayPatients = '0';
  String totalPatients = '0';
  String thisWeek = '0';
  List<Map<String, dynamic>> upcomingSessions = [];

  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDoctorData();
  }

  Future<void> loadDoctorData() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      Map<String, dynamic>? doctorData = await _doctorService.getDoctorData(uid);
      int todayCount = await _doctorService.getTodayPatientCount(uid);
      int totalCount = await _doctorService.getDoctorTotalPatients(uid);
      List<Map<String, dynamic>> sessions = await _doctorService.getDoctorSessions(uid);

      if (mounted) {
        setState(() {
          doctorName = doctorData?['name'] ?? 'Doctor';
          specialization = doctorData?['specialization'] ?? 'Specialist';
          todayPatients = todayCount.toString();
          totalPatients = totalCount.toString();
          thisWeek = sessions.length.toString();
          upcomingSessions = sessions;
          isLoading = false;
        });
      }

    } catch (e) {
      print('Error loading data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _handleBottomNavTap,
        selectedItemColor: AppColors.doctorPrimary,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              color: AppColors.doctorPrimary,
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
                        Text('Welcome back,', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                        Text(doctorName, style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                        Text(specialization, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const LoginScreen());
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.logout, color: AppColors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today\'s Appointments', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                          Text('$todayPatients Patients', style: AppTextStyles.heading2.copyWith(color: AppColors.white)),
                        ],
                      ),
                      const Icon(Icons.people_outline, color: AppColors.white, size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16, mainAxisSpacing: 16,
                    children: [
                      _actionCard(
                        icon: Icons.calendar_month_outlined, iconColor: AppColors.patientPrimary, iconBgColor: AppColors.patientLight,
                        title: 'Appointments', subtitle: 'View queue',
                        onTap: () => _handleBottomNavTap(1),
                      ),
                      _actionCard(
                        icon: Icons.add_circle_outline, iconColor: AppColors.doctorPrimary, iconBgColor: AppColors.doctorLight,
                        title: 'Create Session', subtitle: 'New schedule',
                        onTap: () async {
                          await Get.to(() => const CreateSessionScreen());
                          loadDoctorData();
                        },
                      ),
                      _actionCard(
                        icon: Icons.people_outline, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50,
                        title: 'Patients', subtitle: 'Patient list',
                        onTap: () => Get.to(() => const MyPatientsScreen()),
                      ),
                      _actionCard(
                        icon: Icons.person_outline, iconColor: Colors.orange, iconBgColor: Colors.orange.shade50,
                        title: 'Profile', subtitle: 'Edit details',
                        onTap: () => _handleBottomNavTap(2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Upcoming Sessions', style: AppTextStyles.heading3),
                            Text('View All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.doctorPrimary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        upcomingSessions.isEmpty
                            ? const Padding(padding: EdgeInsets.all(20), child: Text('No upcoming sessions'))
                            : Column(children: upcomingSessions.take(3).map((s) => _sessionItem(s)).toList()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.patientPrimary, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Stats', style: AppTextStyles.label.copyWith(color: AppColors.white)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statColumn('Total Patients', totalPatients),
                            const SizedBox(width: 40),
                            _statColumn('Total Sessions', thisWeek),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
        Text(value, style: AppTextStyles.heading1.copyWith(color: AppColors.white)),
      ],
    );
  }

  Widget _sessionItem(Map<String, dynamic> session) {
    String date = "No Date";
    if (session['date'] != null && session['date'] is Timestamp) {
      date = (session['date'] as Timestamp).toDate().toString().substring(0, 10);
    } else if (session['date'] is DateTime) {
      date = (session['date'] as DateTime).toString().substring(0, 10);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.doctorLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session['title'] ?? 'Session', style: AppTextStyles.label),
                Text('$date | ${session['startTime'] ?? "--"} - ${session['endTime'] ?? "--"}', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.doctorPrimary),
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
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.label, textAlign: TextAlign.center),
            Text(subtitle, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBottomNavTap(int index) async {
    setState(() => currentIndex = index);

    if (index == 1) {
      await Get.to(() => const PatientQueueScreen());
      if (mounted) setState(() => currentIndex = 0);
      return;
    }

    if (index == 2) {
      await Get.to(() => const DoctorProfileScreen());
      await loadDoctorData();
      if (mounted) setState(() => currentIndex = 0);
      return;
    }
  }
}
