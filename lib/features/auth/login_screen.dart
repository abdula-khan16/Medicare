import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicaare/features/auth/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isDockerSelected = false;
  bool isEmailSelected = true;

  Future<void> loginUser() async {

    // Validation
    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading
    setState(() => isLoading = true);

    try {
      // Step 1 - Login with Firebase
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Step 2 - Check role from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .get();

      String role = doc['role'];

      // Step 3 - Go to correct screen
      if (role == 'doctor') {
        Get.offAll(() => const DoctorHomeScreen());
      } else {
        Get.offAll(() => const PatientHomeScreen());
      }

    } catch (e) {
      Get.snackbar('Login Failed', 'Wrong email or password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    // Hide loading
    setState(() => isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.patientPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_liquid_sharp,
                color: AppColors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(AppStrings.welcomeBack, style: AppTextStyles.heading1),
            SizedBox(height: 6),
            Text(AppStrings.loginSubtitle, style: AppTextStyles.bodyMedium),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.textGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDockerSelected = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isDockerSelected
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppStrings.patients,
                          style: AppTextStyles.label.copyWith(
                            color: !isDockerSelected
                                ? AppColors.patientPrimary
                                : AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDockerSelected = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDockerSelected
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Doctor",
                          style: AppTextStyles.label.copyWith(
                            color: isDockerSelected
                                ? AppColors.doctorPrimary
                                : AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.textGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Email Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isEmailSelected = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isEmailSelected
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Email',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(
                            color: isEmailSelected
                                ? AppColors.patientPrimary
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Phone Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isEmailSelected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isEmailSelected
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Phone Number',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(
                            color: !isEmailSelected
                                ? AppColors.patientPrimary
                                : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: AppTextStyles.label,
                hintText: 'Enter your email',
                hintStyle: AppTextStyles.hint,
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: AppTextStyles.label,
                hintText: '••••••••',
                hintStyle: AppTextStyles.hint,
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.patientPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : loginUser,child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Login', style: AppTextStyles.button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: AppTextStyles.bodySmall),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const RegisterScreen());
                  },
                  child: Text(
                    'Sign Up',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.patientPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
