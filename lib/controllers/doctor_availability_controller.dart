import 'package:get/get.dart';
import 'package:doctor_appointments/models/doctor_availability.dart';
import 'package:doctor_appointments/services/database_helper.dart';
import 'package:intl/intl.dart';

class DoctorAvailabilityController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final RxBool isLoading = false.obs;
  final RxList<DoctorAvailability> availabilities = <DoctorAvailability>[].obs;

  Future<void> loadAvailability(int doctorId) async {
    try {
      isLoading.value = true;
      final results = await _dbHelper.getDoctorAvailability(doctorId);
      availabilities.value = results;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAvailability(DoctorAvailability availability) async {
    try {
      final result = await _dbHelper.insertDoctorAvailability(availability);
      if (result > 0) {
        await loadAvailability(availability.doctorId);
        Get.snackbar(
          'Success',
          'Availability added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add availability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateAvailability(DoctorAvailability availability) async {
    try {
      if (availability.id == null) {
        throw Exception('Cannot update availability without an ID');
      }
      final result = await _dbHelper.updateDoctorAvailability(availability);
      if (result > 0) {
        await loadAvailability(availability.doctorId);
        Get.snackbar(
          'Success',
          'Availability updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update availability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteAvailability(DoctorAvailability availability) async {
    try {
      if (availability.id == null) {
        throw Exception('Cannot delete availability without an ID');
      }
      
      final result = await _dbHelper.deleteDoctorAvailability(availability.id!);
      if (result > 0) {
        await loadAvailability(availability.doctorId);
        Get.snackbar(
          'Success',
          'Availability deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete availability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> batchUpdateAvailability(
    List<DoctorAvailability> availabilityList,
  ) async {
    try {
      if (availabilityList.isEmpty) return;
      
      await _dbHelper.batchUpdateDoctorAvailability(availabilityList);
      await loadAvailability(availabilityList.first.doctorId);
      Get.snackbar(
        'Success',
        'Availability updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update availability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<String> generateTimeSlots(String startTime, String endTime, int duration) {
    final slots = <String>[];
    final start = DateFormat.jm().parse(startTime);
    final end = DateFormat.jm().parse(endTime);
    
    var current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('hh:mm a').format(current));
      current = current.add(Duration(minutes: duration));
    }
    
    return slots;
  }

  bool isTimeSlotAvailable(
    DateTime dateTime,
    List<DoctorAvailability> availabilities,
    List<DateTime> bookedSlots,
  ) {
    final dayOfWeek = DateFormat('EEEE').format(dateTime);
    final timeString = DateFormat('hh:mm a').format(dateTime);

    // Check if there's availability for this day
    final dayAvailability = availabilities.where(
      (a) => a.dayOfWeek == dayOfWeek && a.isAvailable,
    );

    if (dayAvailability.isEmpty) return false;

    // Check if the time falls within any availability slot
    for (var availability in dayAvailability) {
      final slots = availability.generateTimeSlots();
      if (slots.contains(timeString)) {
        // Check if the slot is not already booked
        return !bookedSlots.any((booked) =>
            booked.year == dateTime.year &&
            booked.month == dateTime.month &&
            booked.day == dateTime.day &&
            booked.hour == dateTime.hour &&
            booked.minute == dateTime.minute);
      }
    }

    return false;
  }

  List<String> getAvailableTimeSlots(
    DateTime date,
    List<DoctorAvailability> availabilities,
    List<DateTime> bookedSlots,
  ) {
    final dayOfWeek = DateFormat('EEEE').format(date);
    final dayAvailability = availabilities.where(
      (a) => a.dayOfWeek == dayOfWeek && a.isAvailable,
    );

    if (dayAvailability.isEmpty) return [];

    final allSlots = <String>[];
    for (var availability in dayAvailability) {
      allSlots.addAll(availability.generateTimeSlots());
    }

    return allSlots.where((timeString) {
      final slotTime = DateFormat('hh:mm a').parse(timeString);
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        slotTime.hour,
        slotTime.minute,
      );
      return !bookedSlots.any((booked) =>
          booked.year == dateTime.year &&
          booked.month == dateTime.month &&
          booked.day == dateTime.day &&
          booked.hour == dateTime.hour &&
          booked.minute == dateTime.minute);
    }).toList();
  }
}
