import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../doctor_service.dart';
import '../auth/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _doctorService = DoctorService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  bool isSaving = false;
  Map<String, dynamic>? doctorData;
  int totalPatients = 0;
  int sessionsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return;
      
      var data = await _doctorService.getDoctorData(uid);
      int patients = await _doctorService.getDoctorTotalPatients(uid);
      var sessions = await _doctorService.getDoctorSessions(uid);

      if (mounted) {
        setState(() {
          doctorData = data;
          totalPatients = patients;
          sessionsCount = sessions.length;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showEditDialog() {
    final locationController = TextEditingController(text: doctorData?['location'] ?? '');
    final aboutController = TextEditingController(text: doctorData?['about'] ?? '');
    final experienceController = TextEditingController(text: doctorData?['experience']?.toString() ?? '');
    final specializationController = TextEditingController(text: doctorData?['specialization'] ?? '');

    Get.dialog(
      StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: specializationController,
                  decoration: const InputDecoration(labelText: 'Specialization', hintText: 'e.g. Cardiologist'),
                ),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience (years)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location', hintText: 'Clinic address'),
                ),
                TextField(
                  controller: aboutController,
                  decoration: const InputDecoration(labelText: 'About Me'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setDialogState(() => isSaving = true);
                try {
                  String uid = _auth.currentUser!.uid;
                  await _doctorService.updateDoctorProfile(
                    uid: uid,
                    specialization: specializationController.text.trim(),
                    experience: experienceController.text.trim(),
                    location: locationController.text.trim(),
                    about: aboutController.text.trim(),
                  );
                  
                  await _loadProfileData();
                  Get.back();
                  Get.snackbar('Success', 'Profile updated!',
                      backgroundColor: Colors.green, colorText: Colors.white);
                } catch (e) {
                  Get.snackbar('Error', 'Update failed: $e',
                      backgroundColor: Colors.red, colorText: Colors.white);
                } finally {
                  setDialogState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = doctorData?['name'] ?? 'Doctor Name';
    final String specialization = doctorData?['specialization'] ?? 'Specialization';
    final String email = doctorData?['email'] ?? 'No Email';
    final String phone = doctorData?['phone'] ?? 'No Phone';
    final String about = doctorData?['about'] ?? 'No information provided.';
    final String location = doctorData?['location'] ?? 'Not specified';
    final String experience = doctorData?['experience']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
              decoration: const BoxDecoration(
                color: AppColors.doctorPrimary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: AppColors.doctorPrimary, size: 50),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text(specialization, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Contact Information', style: AppTextStyles.heading3),
                            GestureDetector(
                              onTap: _showEditDialog,
                              child: const Icon(Icons.edit, color: AppColors.doctorPrimary, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _infoTile(icon: Icons.email_outlined, iconColor: AppColors.patientPrimary, iconBgColor: AppColors.patientLight, label: 'Email', value: email),
                        const Divider(height: 24),
                        _infoTile(icon: Icons.phone_outlined, iconColor: AppColors.doctorPrimary, iconBgColor: AppColors.doctorLight, label: 'Phone', value: phone),
                        const Divider(height: 24),
                        _infoTile(icon: Icons.work_outline, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50, label: 'Experience', value: '$experience years'),
                        const Divider(height: 24),
                        _infoTile(icon: Icons.location_on_outlined, iconColor: Colors.orange, iconBgColor: Colors.orange.shade50, label: 'Location', value: location),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('About Me', style: AppTextStyles.heading3),
                            GestureDetector(
                              onTap: _showEditDialog,
                              child: Container(
                                width: 32, height: 32,
                                decoration: const BoxDecoration(color: AppColors.patientLight, shape: BoxShape.circle),
                                child: const Icon(Icons.edit_outlined, color: AppColors.patientPrimary, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                        Text('Professional Stats', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        _statRow('Total Patients', totalPatients.toString()),
                        const Divider(height: 16),
                        _statRow('Total Sessions', sessionsCount.toString()),
                        const Divider(height: 16),
                        _statRow('Specialization', specialization),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      await _auth.signOut();
                      Get.offAll(() => const LoginScreen());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text('Logout', style: AppTextStyles.label.copyWith(color: Colors.red.shade700)),
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

  Widget _infoTile({required IconData icon, required Color iconColor, required Color iconBgColor, required String label, required String value}) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(value, style: AppTextStyles.label),
          ],
        ),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.label),
      ],
    );
  }
}
