import 'package:intl/intl.dart';

class DoctorAvailability {
  final int? id;
  final int doctorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDuration; // in minutes
  final bool isAvailable;

  DoctorAvailability({
    this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'slot_duration': slotDuration,
      'is_available': isAvailable ? 1 : 0,
    };
  }

  factory DoctorAvailability.fromMap(Map<String, dynamic> map) {
    return DoctorAvailability(
      id: map['id'] as int?,
      doctorId: map['doctor_id'] as int,
      dayOfWeek: map['day_of_week'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      slotDuration: map['slot_duration'] as int,
      isAvailable: (map['is_available'] as int) == 1,
    );
  }

  DoctorAvailability copyWith({
    int? id,
    int? doctorId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    int? slotDuration,
    bool? isAvailable,
  }) {
    return DoctorAvailability(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotDuration: slotDuration ?? this.slotDuration,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  List<String> generateTimeSlots() {
    final slots = <String>[];
    final start = DateFormat.jm().parse(startTime);
    final end = DateFormat.jm().parse(endTime);
    
    var current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('hh:mm a').format(current));
      current = current.add(Duration(minutes: slotDuration));
    }
    
    return slots;
  }
}