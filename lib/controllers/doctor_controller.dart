import 'package:get/get.dart';
import 'package:doctor_appointments/models/doctor.dart';
import 'package:doctor_appointments/services/database_helper.dart';

class DoctorController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final Rx<Doctor?> selectedDoctor = Rx<Doctor?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    try {
      isLoading.value = true;
      final List<Map<String, dynamic>> doctorMaps = await _dbHelper.getAllDoctors();
      doctors.value = doctorMaps.map((map) => Doctor.fromMap(map)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctors: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDoctorById(int id) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic>? doctorMap = await _dbHelper.getDoctorById(id);
      if (doctorMap != null) {
        selectedDoctor.value = Doctor.fromMap(doctorMap);
      } else {
        selectedDoctor.value = null;
        Get.snackbar('Error', 'Doctor not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctor: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addDoctor(Doctor doctor) async {
    try {
      isLoading.value = true;
      final result = await _dbHelper.insertDoctor(doctor.toMap());
      if (result > 0) {
        await loadDoctors(); // Refresh the list
        Get.snackbar('Success', 'Doctor added successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add doctor: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDoctor(Doctor doctor) async {
    try {
      if (doctor.id == null) {
        Get.snackbar('Error', 'Doctor ID is required for update');
        return false;
      }
      
      isLoading.value = true;
      final result = await _dbHelper.updateDoctor(doctor.toMap());
      if (result > 0) {
        await loadDoctors(); // Refresh the list
        if (selectedDoctor.value?.id == doctor.id) {
          selectedDoctor.value = doctor;
        }
        Get.snackbar('Success', 'Doctor updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update doctor: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteDoctor(int id) async {
    try {
      isLoading.value = true;
      final result = await _dbHelper.deleteDoctor(id);
      if (result > 0) {
        await loadDoctors(); // Refresh the list
        if (selectedDoctor.value?.id == id) {
          selectedDoctor.value = null;
        }
        Get.snackbar('Success', 'Doctor deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete doctor: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void selectDoctor(Doctor doctor) {
    selectedDoctor.value = doctor;
  }

  void clearSelection() {
    selectedDoctor.value = null;
  }

  List<Doctor> getDoctorsBySpecialty(String specialty) {
    return doctors.where((doctor) => 
      doctor.specialization.toLowerCase() == specialty.toLowerCase()
    ).toList();
  }

  List<Doctor> getTopRatedDoctors({int limit = 10}) {
    final sortedDoctors = List<Doctor>.from(doctors);
    sortedDoctors.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedDoctors.take(limit).toList();
  }

  List<Doctor> getMostExperiencedDoctors({int limit = 10}) {
    final sortedDoctors = List<Doctor>.from(doctors);
    sortedDoctors.sort((a, b) => b.experience.compareTo(a.experience));
    return sortedDoctors.take(limit).toList();
  }

  Future<void> refreshDoctors() async {
    await loadDoctors();
  }
}
