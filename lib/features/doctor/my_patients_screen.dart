import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../doctor_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class MyPatientsScreen extends StatefulWidget {
  const MyPatientsScreen({super.key});

  @override
  State<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends State<MyPatientsScreen> {
  final DoctorService _doctorService = DoctorService();
  final searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _patientsFuture;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
    searchController.addListener(() {
      if (!mounted) return;
      setState(() => _searchText = searchController.text.trim().toLowerCase());
    });
  }

  void _loadPatients() {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    _patientsFuture = doctorId == null
        ? Future.value([])
        : _doctorService.getDoctorPatients(doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Green Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.doctorPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Patients',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _patientsFuture,
                          builder: (context, snapshot) {
                            final total = snapshot.data?.length ?? 0;
                            return Text(
                              '$total total patients',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: AppColors.textGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText:
                            'Search by name, email, or condition',
                            hintStyle: AppTextStyles.hint,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Patient List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _patientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final patients = snapshot.data ?? [];
                final filtered = patients.where((p) {
                  if (_searchText.isEmpty) return true;
                  final name = (p['name'] ?? '').toString().toLowerCase();
                  final email = (p['email'] ?? '').toString().toLowerCase();
                  final phone = (p['phone'] ?? '').toString().toLowerCase();
                  return name.contains(_searchText) ||
                      email.contains(_searchText) ||
                      phone.contains(_searchText);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      patients.isEmpty
                          ? 'No patients found yet.'
                          : 'No patient matches your search.',
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _patientCard(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientCard(Map<String, dynamic> patient) {
    final String allergies = (patient['allergies'] ?? '').toString().trim();
    List<String> conditions = allergies.isEmpty
        ? []
        : allergies
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Name + Visits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.doctorLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.doctorPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(patient['name'], style: AppTextStyles.label),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.patientLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Patient',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.patientPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Age + Gender + Last Visit
          if ((patient['dob'] ?? '').toString().isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DOB: ${patient['dob']}',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Phone
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 4),
              Text((patient['phone'] ?? '-').toString(),
                  style: AppTextStyles.bodySmall),
            ],
          ),

          const SizedBox(height: 4),

          // Email
          Row(
            children: [
              const Icon(Icons.email_outlined,
                  color: AppColors.textGrey, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  (patient['email'] ?? '-').toString(),
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Medical Conditions
          if (conditions.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Medical Conditions / Allergies',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                children: conditions
                    .map(
                      (condition) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      condition,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // View Medical History Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Info',
                  'Medical history module coming soon',
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Medical History',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}