import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doctor_appointments/models/appointment.dart';
import 'package:doctor_appointments/models/doctor_availability.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'doctor_appointments.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Create doctors table
        await db.execute('''
          CREATE TABLE doctors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            specialization TEXT NOT NULL,
            phone TEXT,
            email TEXT,
            address TEXT,
            experience INTEGER,
            rating REAL
          )
        ''');

        // Create appointments table
        await db.execute('''
          CREATE TABLE appointments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            doctor_id INTEGER NOT NULL,
            doctor_name TEXT NOT NULL,
            date_time TEXT NOT NULL,
            status TEXT NOT NULL,
            notes TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
              ON DELETE CASCADE,
            FOREIGN KEY (doctor_id) REFERENCES doctors (id)
              ON DELETE CASCADE
          )
        ''');

        // Create doctor_availability table
        await db.execute('''
          CREATE TABLE doctor_availability (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            doctor_id INTEGER NOT NULL,
            day_of_week TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            slot_duration INTEGER NOT NULL,
            is_available INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (doctor_id) REFERENCES doctors (id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // User methods
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Doctor methods
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    return await db.query('doctors');
  }

  Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(String specialty) async {
    final db = await database;
    return await db.query(
      'doctors',
      where: 'specialization = ?',
      whereArgs: [specialty],
    );
  }

  Future<Map<String, dynamic>?> getDoctorById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );

    return maps.isNotEmpty ? maps.first : null;
  }
  Future<int> insertDoctor(Map<String, dynamic> doctor) async {
    final db = await database;
    return await db.insert(
      'doctors',
      doctor,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDoctor(Map<String, dynamic> doctor) async {
    final db = await database;
    return await db.update(
      'doctors',
      doctor,
      where: 'id = ?',
      whereArgs: [doctor['id']],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await database;
    return await db.delete(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    final db = await database;
    return await db.query(
      'doctors',
      where: 'name LIKE ? OR specialization LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }
  // Appointment methods
  Future<List<Appointment>> getAppointmentsByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByDoctorId(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
    );

    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert(
      'appointments',
      appointment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Doctor Availability methods
  Future<List<DoctorAvailability>> getDoctorAvailability(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_availability',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
    );

    return maps.map((map) => DoctorAvailability.fromMap(map)).toList();
  }

  Future<List<DoctorAvailability>> getDoctorAvailabilityForDay(
    int doctorId,
    String dayOfWeek,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_availability',
      where: 'doctor_id = ? AND day_of_week = ? AND is_available = 1',
      whereArgs: [doctorId, dayOfWeek],
    );

    return maps.map((map) => DoctorAvailability.fromMap(map)).toList();
  }

  Future<int> insertDoctorAvailability(DoctorAvailability availability) async {
    final db = await database;
    final map = availability.toMap();
    return await db.insert(
      'doctor_availability',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDoctorAvailability(DoctorAvailability availability) async {
    final db = await database;
    return await db.update(
      'doctor_availability',
      availability.toMap(),
      where: 'id = ?',
      whereArgs: [availability.id],
    );
  }

  Future<int> deleteDoctorAvailability(int id) async {
    final db = await database;
    return await db.delete(
      'doctor_availability',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> batchUpdateDoctorAvailability(
    List<DoctorAvailability> availabilities,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (var availability in availabilities) {
      if (availability.id != null) {
        batch.update(
          'doctor_availability',
          availability.toMap(),
          where: 'id = ?',
          whereArgs: [availability.id],
        );
      } else {
        batch.insert(
          'doctor_availability',
          availability.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
  }
}