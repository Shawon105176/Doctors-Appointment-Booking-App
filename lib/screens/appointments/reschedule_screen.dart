import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:doctor_appointments/models/appointment.dart';
import 'package:doctor_appointments/controllers/appointment_controller.dart';
import 'package:doctor_appointments/controllers/doctor_availability_controller.dart';
import 'package:doctor_appointments/services/database_helper.dart';
import 'package:doctor_appointments/utils/theme.dart';

class RescheduleScreen extends StatefulWidget {
  final Appointment appointment;

  const RescheduleScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  final _appointmentController = Get.find<AppointmentController>();
  final _availabilityController = Get.put(DoctorAvailabilityController());
  final _dbHelper = DatabaseHelper();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTime;
  List<String> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    try {
      // Get doctor availability
      final availabilities = await _dbHelper.getDoctorAvailability(widget.appointment.doctorId);
      
      // Get existing appointments for this doctor on the selected day
      final existingAppointments = await _dbHelper.getAppointmentsByDoctorId(widget.appointment.doctorId);
      final bookedSlots = existingAppointments
          .where((apt) => 
              apt.dateTime.year == _selectedDay.year &&
              apt.dateTime.month == _selectedDay.month &&
              apt.dateTime.day == _selectedDay.day)
          .map((apt) => apt.dateTime)
          .toList();
      
      // Get available slots using the availability controller
      final slots = _availabilityController.getAvailableTimeSlots(
        _selectedDay,
        availabilities,
        bookedSlots,
      );
      
      setState(() {
        _availableTimeSlots = slots;
        _selectedTime = null;
      });
    } catch (e) {
      setState(() {
        _availableTimeSlots = [];
        _selectedTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Appointment',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(widget.appointment.dateTime)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Time: ${DateFormat('hh:mm a').format(widget.appointment.dateTime)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select New Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTime = null;
                  });
                  _loadTimeSlots();
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select New Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_availableTimeSlots.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No available time slots for this date',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: time == _selectedTime,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTime = selected ? time : null;
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTime == null ? null : _handleReschedule,
                child: const Text('Confirm Reschedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _handleReschedule() async {
    // Parse the selected time to create a new DateTime
    final timeFormat = DateFormat('hh:mm a');
    final timeOnly = timeFormat.parse(_selectedTime!);
    
    final newDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      timeOnly.hour,
      timeOnly.minute,
    );
    
    // Create updated appointment with new date and time
    final updatedAppointment = widget.appointment.copyWith(
      dateTime: newDateTime,
    );
    
    final success = await _appointmentController.rescheduleAppointment(updatedAppointment);

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Appointment rescheduled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}