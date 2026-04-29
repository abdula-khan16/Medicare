import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicaare/features/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isDockerSelected = false;
  bool isEmailVerify = true;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> registerUser() async {

    // Validation
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (emailController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter phone number',
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
      // Check if phone already exists in Firestore
      QuerySnapshot phoneCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneController.text.trim())
          .get();

      if (phoneCheck.docs.isNotEmpty) {
        Get.snackbar('Error', 'Phone number already registered!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() => isLoading = false);
        return;
      }
      // Step 1 - Create user in Firebase Auth
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Step 2 - Save user data in Firestore
      String role = isDockerSelected ? 'doctor' : 'patient';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': role,
        'createdAt': DateTime.now(),
      });

      // Step 3 - Go to correct home screen
      if (role == 'doctor') {
        Get.offAll(() => const DoctorHomeScreen());
      } else {
        Get.offAll(() => const PatientHomeScreen());
      }

    } catch (e) {
      Get.snackbar('Register Failed', e.toString(),
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
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.patientPrimary,
                ),
                child: Icon(
                  Icons.medication_liquid_sharp,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(AppStrings.createAccount, style: AppTextStyles.heading1),
              SizedBox(height: 16),
              Text(AppStrings.joinToday, style: AppTextStyles.bodyMedium),
              SizedBox(height: 40),
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
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
              SizedBox(height: 16),
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
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: AppTextStyles.label,
                  hintText: 'Enter your Phone Number',
                  hintStyle: AppTextStyles.hint,
                  prefixIcon: Icon(Icons.phone),
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
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.patientLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.patientPrimary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verify Account Via', style: AppTextStyles.label),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Email button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isEmailVerify = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isEmailVerify
                                    ? AppColors.patientPrimary
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Email',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.label.copyWith(
                                  color: isEmailVerify
                                      ? AppColors.white
                                      : AppColors.textGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Phone SMS button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isEmailVerify = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isEmailVerify
                                    ? AppColors.patientPrimary
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Phone (SMS)',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.label.copyWith(
                                  color: !isEmailVerify
                                      ? AppColors.white
                                      : AppColors.textGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll send a verification code to your email",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.patientPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              //sign up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign Up', style: AppTextStyles.button),
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
                  Text(
                    AppStrings.alreadyHaveAccount,
                    style: AppTextStyles.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const LoginScreen());
                    },
                    child: Text(
                      'Login',
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
      ),
    );
  }
}
