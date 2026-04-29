import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../patient_service.dart';
import '../auth/login_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final PatientService _patientService = PatientService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  bool isSaving = false;
  Map<String, dynamic>? patientData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return;
      var data = await _patientService.getPatientData(uid);
      if (mounted) {
        setState(() {
          patientData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: patientData?['name'] ?? '');
    final phoneController = TextEditingController(text: patientData?['phone'] ?? '');
    final dobController = TextEditingController(text: patientData?['dob'] ?? '');
    final addressController = TextEditingController(text: patientData?['address'] ?? '');
    final bloodGroupController = TextEditingController(text: patientData?['bloodGroup'] ?? '');
    final allergiesController = TextEditingController(text: patientData?['allergies'] ?? '');
    final emergencyController = TextEditingController(text: patientData?['emergencyContact'] ?? '');

    Get.dialog(
      StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField(nameController, 'Full Name'),
                _editField(phoneController, 'Phone Number'),
                _editField(dobController, 'Date of Birth (e.g. Jan 15, 1990)'),
                _editField(addressController, 'Address'),
                _editField(bloodGroupController, 'Blood Group (e.g. O+)'),
                _editField(allergiesController, 'Allergies'),
                _editField(emergencyController, 'Emergency Contact'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: isSaving ? null : () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setDialogState(() => isSaving = true);
                try {
                  await _patientService.updatePatientProfile(
                    uid: _auth.currentUser!.uid,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    dob: dobController.text.trim(),
                    address: addressController.text.trim(),
                    bloodGroup: bloodGroupController.text.trim(),
                    allergies: allergiesController.text.trim(),
                    emergencyContact: emergencyController.text.trim(),
                  );
                  await _loadProfileData();
                  Get.back();
                  Get.snackbar('Success', 'Profile updated!', backgroundColor: Colors.green, colorText: Colors.white);
                } catch (e) {
                  Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
                } finally {
                  setDialogState(() => isSaving = false);
                }
              },
              child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
            ),
          ],
        );
      }),
    );
  }

  Widget _editField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                    child: const Icon(Icons.person, color: AppColors.patientPrimary, size: 50),
                  ),
                  const SizedBox(height: 12),
                  Text(patientData?['name'] ?? 'Patient Name', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text('Patient', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Personal Information', style: AppTextStyles.heading3),
                            GestureDetector(onTap: _showEditDialog, child: const Icon(Icons.edit, color: AppColors.patientPrimary, size: 20)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _infoTile(icon: Icons.email_outlined, iconColor: AppColors.patientPrimary, iconBgColor: AppColors.patientLight, label: 'Email', value: patientData?['email'] ?? 'No Email'),
                        const Divider(height: 24),
                        _infoTile(icon: Icons.phone_outlined, iconColor: AppColors.doctorPrimary, iconBgColor: AppColors.doctorLight, label: 'Phone', value: patientData?['phone'] ?? 'No Phone'),
                        const Divider(height: 24),
                        _infoTile(icon: Icons.calendar_month_outlined, iconColor: Colors.purple, iconBgColor: Colors.purple.shade50, label: 'Date of Birth', value: patientData?['dob'] ?? 'Not set'),
                        const Divider(height: 24),
                        _infoTile(icon: Icons.location_on_outlined, iconColor: Colors.orange, iconBgColor: Colors.orange.shade50, label: 'Address', value: patientData?['address'] ?? 'Not set'),
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
                        Text('Medical Information', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        _medicalRow('Blood Type', patientData?['bloodGroup'] ?? 'Not set'),
                        const Divider(height: 16),
                        _medicalRow('Allergies', patientData?['allergies'] ?? 'None'),
                        const Divider(height: 16),
                        _medicalRow('Emergency Contact', patientData?['emergencyContact'] ?? 'Not set'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showEditDialog,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.patientPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
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
        Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTextStyles.bodySmall), Text(value, style: AppTextStyles.label)])),
      ],
    );
  }

  Widget _medicalRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.bodySmall), Text(value, style: AppTextStyles.label)]);
  }
}
