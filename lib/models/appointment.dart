class Appointment {
  final int? id;
  final int userId;
  final int doctorId;
  final String doctorName;
  final DateTime dateTime;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;

  Appointment({
    this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      doctorId: map['doctor_id'] as int,
      doctorName: map['doctor_name'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      status: map['status'] as String,
      notes: map['notes'] as String?,
    );
  }

  Appointment copyWith({
    int? id,
    int? userId,
    int? doctorId,
    String? doctorName,
    DateTime? dateTime,
    String? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}