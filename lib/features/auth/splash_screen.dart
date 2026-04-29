import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 3 seconds then go to Role Selection Screen
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => const RoleSelectionScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Circle
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.patientPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_liquid_sharp,
                color: AppColors.white,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              AppStrings.appName,
              style: AppTextStyles.heading1,
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              AppStrings.tagline,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}