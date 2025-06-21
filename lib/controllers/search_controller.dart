import 'package:get/get.dart';
import 'package:doctor_appointments/models/doctor.dart';
import 'package:doctor_appointments/services/database_helper.dart';

class SearchController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  final RxList<Doctor> searchResults = <Doctor>[].obs;
  final RxList<Doctor> allDoctors = <Doctor>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSpecialty = 'All'.obs;
  final RxBool isLoading = false.obs;

  final List<String> specialties = [
    'All',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'General Medicine',
  ];

  @override
  void onInit() {
    super.onInit();
    loadAllDoctors();
  }

  Future<void> loadAllDoctors() async {
    try {
      isLoading.value = true;
      final List<Map<String, dynamic>> doctorMaps = await _dbHelper.getAllDoctors();
      allDoctors.value = doctorMaps.map((map) => Doctor.fromMap(map)).toList();
      searchResults.value = allDoctors;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctors: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDoctors(String query) async {
    try {
      isLoading.value = true;
      searchQuery.value = query;

      List<Map<String, dynamic>> results = [];

      if (query.isEmpty) {
        // If no search query, filter by specialty only
        if (selectedSpecialty.value == 'All') {
          results = await _dbHelper.getAllDoctors();
        } else {
          results = await _dbHelper.getDoctorsBySpecialty(selectedSpecialty.value);
        }
      } else {
        // Search with query
        results = await _dbHelper.searchDoctors(query);
        
        // Filter by specialty if not 'All'
        if (selectedSpecialty.value != 'All') {
          results = results.where((doctor) => 
            doctor['specialization'] == selectedSpecialty.value
          ).toList();
        }
      }

      searchResults.value = results.map((map) => Doctor.fromMap(map)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to search doctors: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterBySpecialty(String specialty) async {
    try {
      isLoading.value = true;
      selectedSpecialty.value = specialty;

      List<Map<String, dynamic>> results = [];

      if (specialty == 'All') {
        if (searchQuery.value.isEmpty) {
          results = await _dbHelper.getAllDoctors();
        } else {
          results = await _dbHelper.searchDoctors(searchQuery.value);
        }
      } else {
        if (searchQuery.value.isEmpty) {
          results = await _dbHelper.getDoctorsBySpecialty(specialty);
        } else {
          // Search with query and filter by specialty
          final searchResults = await _dbHelper.searchDoctors(searchQuery.value);
          results = searchResults.where((doctor) => 
            doctor['specialization'] == specialty
          ).toList();
        }
      }

      searchResults.value = results.map((map) => Doctor.fromMap(map)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter doctors: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    selectedSpecialty.value = 'All';
    searchResults.value = allDoctors;
  }

  Future<void> refreshDoctors() async {
    await loadAllDoctors();
  }
  // Get doctors by rating (high to low)
  List<Doctor> getDoctorsByRating() {
    final doctors = List<Doctor>.from(searchResults);
    doctors.sort((a, b) => b.rating.compareTo(a.rating));
    return doctors;
  }

  // Get doctors by experience (high to low)
  List<Doctor> getDoctorsByExperience() {
    final doctors = List<Doctor>.from(searchResults);
    doctors.sort((a, b) => b.experience.compareTo(a.experience));
    return doctors;
  }

  // Get nearby doctors (placeholder - would need location logic)
  List<Doctor> getNearbyDoctors() {
    return searchResults; // For now, return all results
  }
}