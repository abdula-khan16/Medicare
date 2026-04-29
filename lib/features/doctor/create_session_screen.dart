import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../doctor_service.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final DoctorService _doctorService = DoctorService();
  
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final gapController = TextEditingController(text: '15');
  
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool isRecurring = false;
  bool isLoading = false;

  // Date Picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Time Picker
  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          selectedStartTime = picked;
          startTimeController.text = picked.format(context);
        } else {
          selectedEndTime = picked;
          endTimeController.text = picked.format(context);
        }
      });
    }
  }

  // Save Session
  Future<void> _createSession() async {
    if (titleController.text.isEmpty || selectedDate == null || selectedStartTime == null || selectedEndTime == null) {
      Get.snackbar('Error', 'Please fill all required fields', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      await _doctorService.createSession(
        doctorId: uid,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: selectedDate!,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        gapBetweenPatients: int.parse(gapController.text),
        isRecurring: isRecurring,
      );

      Get.back(); // Go back to Home
      Get.snackbar('Success', 'Session created successfully!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create session: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
              decoration: const BoxDecoration(
                color: AppColors.doctorPrimary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Create Session', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
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
                        Text('Session Title', style: AppTextStyles.label),
                        const SizedBox(height: 12),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Morning Consultation',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Description', style: AppTextStyles.label),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Brief description (optional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey.shade50,
                          ),
                        ),
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
                        Text('Date', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          controller: dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: InputDecoration(
                            hintText: 'Select date',
                            prefixIcon: const Icon(Icons.calendar_month),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start Time', style: AppTextStyles.bodySmall),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: startTimeController,
                                    readOnly: true, onTap: () => _selectTime(true),
                                    decoration: InputDecoration(
                                      hintText: 'Time',
                                      prefixIcon: const Icon(Icons.access_time),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true, fillColor: Colors.grey.shade50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('End Time', style: AppTextStyles.bodySmall),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: endTimeController,
                                    readOnly: true, onTap: () => _selectTime(false),
                                    decoration: InputDecoration(
                                      hintText: 'Time',
                                      prefixIcon: const Icon(Icons.access_time),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true, fillColor: Colors.grey.shade50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Gap (minutes)', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 8),
                        TextField(
                          controller: gapController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Repeat Weekly', style: AppTextStyles.label),
                        Switch(
                          value: isRecurring,
                          onChanged: (v) => setState(() => isRecurring = v),
                          activeColor: AppColors.doctorPrimary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _createSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.doctorPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Create Session', style: AppTextStyles.button),
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
}
