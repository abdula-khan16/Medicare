import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../doctor_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class WritePrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final String appointmentId;

  const WritePrescriptionScreen({
    super.key,
    required this.patientData,
    required this.appointmentId,
  });

  @override
  State<WritePrescriptionScreen> createState() => _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  final DoctorService _doctorService = DoctorService();
  final List<Map<String, TextEditingController>> _medicines = [
    {'name': TextEditingController(), 'dosage': TextEditingController(), 'instructions': TextEditingController()}
  ];
  final notesController = TextEditingController();
  bool isLoading = false;

  void _addMedicine() {
    setState(() {
      _medicines.add({'name': TextEditingController(), 'dosage': TextEditingController(), 'instructions': TextEditingController()});
    });
  }

  Future<void> _savePrescription() async {
    final medicinesData = _medicines
        .map((m) => {
              'name': m['name']!.text.trim(),
              'dosage': m['dosage']!.text.trim(),
              'instructions': m['instructions']!.text.trim(),
            })
        .where((m) => m['name']!.isNotEmpty)
        .toList();

    if (medicinesData.isEmpty) {
      Get.snackbar('Error', 'Add at least one medicine name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);
    try {
      await _doctorService.writePrescription(
        appointmentId: widget.appointmentId,
        patientId: widget.patientData['patientId'],
        doctorId: widget.patientData['doctorId'],
        doctorName: widget.patientData['doctorName'] ?? 'Doctor',
        patientName: widget.patientData['name'] ?? 'Patient',
        medicines: medicinesData,
        notes: notesController.text.trim(),
      );

      Get.back();
      Get.snackbar('Success', 'Prescription saved and checkup completed!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Write Prescription', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.doctorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: ${widget.patientData['name']}', style: AppTextStyles.heading3),
            const SizedBox(height: 24),
            Text('Medicines', style: AppTextStyles.label),
            const SizedBox(height: 12),
            Column(
              children: _medicines.map((m) => _medicineForm(m)).toList(),
            ),
            TextButton.icon(
              onPressed: _addMedicine,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Medicine'),
            ),
            const SizedBox(height: 24),
            Text('Doctor Notes', style: AppTextStyles.label),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add advice or notes here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _savePrescription,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.doctorPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save & Complete', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicineForm(Map<String, TextEditingController> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          TextField(controller: m['name'], decoration: const InputDecoration(labelText: 'Medicine Name (e.g. Panadol)')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: m['dosage'], decoration: const InputDecoration(labelText: 'Dosage (1-0-1)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: m['instructions'], decoration: const InputDecoration(labelText: 'Instructions (After food)'))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final medicine in _medicines) {
      medicine['name']?.dispose();
      medicine['dosage']?.dispose();
      medicine['instructions']?.dispose();
    }
    notesController.dispose();
    super.dispose();
  }
}
