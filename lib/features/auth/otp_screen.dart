import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, size: 20),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Phone Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.doctorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: AppColors.doctorPrimary,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Verify Your Phone',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "We've sent a 6-digit code to",
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: 4),

              // Phone Number
              Text(
                '+1 234 567 8900',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.patientPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // OTP boxes
              Text('Enter Verification Code', style: AppTextStyles.label),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Verify Code', style: AppTextStyles.button),
                ),
              ),

              const SizedBox(height: 16),

              // Resend text
              Text(
                'Resend code in 53s',
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: 24),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.patientLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Didn't receive the code? Check your messages or try resending.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.patientPrimary,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
