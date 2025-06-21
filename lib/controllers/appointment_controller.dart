import 'package:get/get.dart';
import 'package:doctor_appointments/models/appointment.dart';
import 'package:doctor_appointments/services/database_helper.dart';
import 'package:doctor_appointments/services/preferences_service.dart';
import 'package:doctor_appointments/services/mock_notification_service.dart';

class AppointmentController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PreferencesService _prefsService = Get.find<PreferencesService>();
  final MockNotificationService _notificationService = Get.find<MockNotificationService>();
  
  final RxList<Appointment> upcomingAppointments = <Appointment>[].obs;
  final RxList<Appointment> pastAppointments = <Appointment>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      isLoading.value = true;
      final userId = await _prefsService.getUserId();
      if (userId != null) {
        final appointments = await _dbHelper.getAppointmentsByUserId(userId);
        final now = DateTime.now();
        
        upcomingAppointments.value = appointments
            .where((apt) => apt.dateTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
            
        pastAppointments.value = appointments
            .where((apt) => apt.dateTime.isBefore(now))
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> bookAppointment(Appointment appointment) async {
    try {
      final result = await _dbHelper.insertAppointment(appointment);
      if (result > 0) {
        // Update the appointment with the new ID
        final updatedAppointment = appointment.copyWith(id: result);
        // Schedule notifications for the appointment
        await _scheduleAppointmentNotifications(updatedAppointment);
        await loadAppointments();
        Get.snackbar(
          'Success',
          'Appointment booked successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to book appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> rescheduleAppointment(Appointment appointment) async {
    try {
      if (appointment.id == null) {
        throw Exception('Appointment ID is required for rescheduling');
      }
      
      // Cancel existing notifications for this appointment
      await _notificationService.cancelNotification(appointment.id!);
      
      final result = await _dbHelper.updateAppointment(appointment);
      if (result > 0) {
        // Schedule new notifications for the rescheduled appointment
        await _scheduleAppointmentNotifications(appointment);
        await loadAppointments();
        Get.snackbar(
          'Success',
          'Appointment rescheduled successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reschedule appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      // Cancel notifications for this appointment
      await _notificationService.cancelNotification(appointmentId);
      
      final result = await _dbHelper.deleteAppointment(appointmentId);
      if (result > 0) {
        await loadAppointments();
        Get.snackbar(
          'Success',
          'Appointment cancelled successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> _scheduleAppointmentNotifications(Appointment appointment) async {
    if (appointment.id == null) return;

    // Schedule reminder 1 day before
    final oneDayBefore = appointment.dateTime.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: appointment.id! * 10 + 1, // Unique ID for 1-day reminder
        title: 'Upcoming Appointment Reminder',
        body: 'You have an appointment with Dr. ${appointment.doctorName} tomorrow at ${_formatTime(appointment.dateTime)}',
        scheduledDate: oneDayBefore,
        payload: appointment.id.toString(),
      );
    }

    // Schedule reminder 1 hour before
    final oneHourBefore = appointment.dateTime.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: appointment.id! * 10 + 2, // Unique ID for 1-hour reminder
        title: 'Upcoming Appointment Alert',
        body: 'Your appointment with Dr. ${appointment.doctorName} is in 1 hour at ${_formatTime(appointment.dateTime)}',
        scheduledDate: oneHourBefore,
        payload: appointment.id.toString(),
      );
    }

    // Schedule reminder 15 minutes before
    final fifteenMinsBefore = appointment.dateTime.subtract(const Duration(minutes: 15));
    if (fifteenMinsBefore.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: appointment.id! * 10 + 3, // Unique ID for 15-min reminder
        title: 'Appointment Starting Soon',
        body: 'Your appointment with Dr. ${appointment.doctorName} starts in 15 minutes',
        scheduledDate: fifteenMinsBefore,
        payload: appointment.id.toString(),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}