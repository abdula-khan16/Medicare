import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import 'login_screen.dart';


class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
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
              child:
              const Icon(
                Icons.medication_liquid_sharp,
                color: AppColors.white,
                size: 40,
            )
            ),
            SizedBox(height: 16),
            Text(AppStrings.appName,style: AppTextStyles.heading2,),

            SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                Get.to(() => const LoginScreen());
              },
               child:Container(
                 padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AppColors.white,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.grey.shade200)
                 ),
                 child: Row(
                   children: [
                     Container(
                       width: 56,
                       height: 56,
                       decoration: BoxDecoration(
                         color: AppColors.patientLight,
                         shape: BoxShape.circle,
                     ),
                       child: Icon(Icons.person,color: AppColors.patientPrimary,size: 28),
                     ),
                     SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.iAmPatient,style: AppTextStyles.label),
                          Text(AppStrings.patientDesc,style: AppTextStyles.bodySmall),
                        ],
                      )
                   ],
                 ),
               )
            ),
            SizedBox(height: 16,),
            GestureDetector(
                onTap: () {},
                child:Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.patientLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.medication_liquid_sharp,color: AppColors.patientPrimary,size: 28),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.iAmDoctor,style: AppTextStyles.label),
                          Text(AppStrings.doctorDesc,style: AppTextStyles.bodySmall),
                        ],
                      )
                    ],
                  ),
                )
            )
          ]
        ),
      )
    );
  }
}






















