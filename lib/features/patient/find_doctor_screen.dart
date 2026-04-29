import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../doctor_service.dart';
import 'doctor_detail_screen.dart';

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  final DoctorService _doctorService = DoctorService();
  List<Map<String, dynamic>> allDoctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      var doctors = await _doctorService.getAllDoctors();
      if (mounted) {
        setState(() {
          allDoctors = doctors;
          filteredDoctors = doctors;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      filteredDoctors = allDoctors
          .where((doc) =>
              (doc['name'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (doc['specialization'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(AppStrings.findDoctors, style: AppTextStyles.heading2.copyWith(color: AppColors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterDoctors,
                          decoration: const InputDecoration(
                            hintText: AppStrings.searchDoctors,
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDoctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDoctors[index];
                          return _doctorCard(
                            name: doc['name'] ?? 'Doctor',
                            specialization: doc['specialization'] ?? 'Specialist',
                            rating: (doc['rating'] ?? 0.0).toString(),
                            location: doc['location'] ?? 'Not specified',
                            onTap: () => Get.to(() => DoctorDetailScreen(doctorData: doc)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _doctorCard({required String name, required String specialization, required String rating, required String location, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: const BoxDecoration(color: AppColors.patientLight, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: AppColors.patientPrimary, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(specialization, style: AppTextStyles.bodySmall.copyWith(color: AppColors.patientPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: AppTextStyles.bodySmall),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, color: AppColors.textGrey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(child: Text(location, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
                    ],
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
