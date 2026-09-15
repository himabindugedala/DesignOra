import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';
import '../data/dummy_data.dart';
import '../data/college_config.dart';

class AppState extends ChangeNotifier {
  static const _studentsKey = 'cch_registered_students';
  static const _sessionKey = 'cch_current_student_id';
  static const _themeKey = 'cch_dark_mode';

  Student? _currentStudent;
  List<Student> _registeredStudents = [];
  late List<Booking> _bookings;
  ThemeMode _themeMode = ThemeMode.light;
  SharedPreferences? _prefs;

  AppState() {
    _bookings = DummyData.getInitialBookings();
  }

  Future<void> loadPersistedData() async {
    _prefs = await SharedPreferences.getInstance();

    final encoded = _prefs!.getString(_studentsKey);
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final decoded = jsonDecode(encoded) as List<dynamic>;
        _registeredStudents = decoded
            .map((item) => Student.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } catch (_) {
        _registeredStudents = [];
      }
    }

    _themeMode = (_prefs!.getBool(_themeKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;

    final sessionId = _prefs!.getString(_sessionKey);
    if (sessionId != null) {
      final match = _registeredStudents.where((s) => s.id == sessionId);
      if (match.isNotEmpty && match.first.isApproved) {
        _currentStudent = match.first;
      } else {
        await _prefs!.remove(_sessionKey);
      }
    }
  }

  Student? get currentStudent => _currentStudent;
  bool get isAuthenticated => _currentStudent != null;
  List<Student> get registeredStudents => List.unmodifiable(_registeredStudents);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _saveStudents() async {
    await _prefs?.setString(
      _studentsKey,
      jsonEncode(_registeredStudents.map((student) => student.toJson()).toList()),
    );
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs?.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Student? findStudent({required String regNumber, required String phone}) {
    final cleanReg = regNumber.trim().toUpperCase();
    final cleanPhone = phone.trim();
    for (final student in _registeredStudents) {
      if (student.regNumber.toUpperCase() == cleanReg &&
          student.phone == cleanPhone) {
        return student;
      }
    }
    return null;
  }

  Future<bool> login({required String regNumber, required String phone}) async {
    final match = findStudent(regNumber: regNumber, phone: phone);
    if (match == null || !match.isApproved) return false;

    _currentStudent = match;
    await _prefs?.setString(_sessionKey, match.id);
    notifyListeners();
    return true;
  }

  Future<void> registerStudent(Student student) async {
    final index = _registeredStudents.indexWhere(
      (s) => s.regNumber.toUpperCase() == student.regNumber.toUpperCase(),
    );
    if (index != -1) {
      _registeredStudents[index] = student;
    } else {
      _registeredStudents.add(student);
    }
    await _saveStudents();
    notifyListeners();
  }

  Future<void> approveStudent(String studentId) async {
    final index = _registeredStudents.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final approved = _registeredStudents[index].copyWith(isApproved: true);
    _registeredStudents[index] = approved;
    await _saveStudents();
    notifyListeners();
  }

  Future<void> updateProfile(Student student) async {
    final index = _registeredStudents.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _registeredStudents[index] = student;
      if (_currentStudent?.id == student.id) _currentStudent = student;
      await _saveStudents();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _currentStudent = null;
    await _prefs?.remove(_sessionKey);
    notifyListeners();
  }

  List<Booking> getStudentBookings() {
    if (_currentStudent == null) return [];
    return _bookings
        .where((b) => b.studentId == _currentStudent!.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Booking> getUpcomingBookings() {
    final list = getStudentBookings().where((b) => b.isUpcoming).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<Booking> getPastBookings() {
    final list = getStudentBookings().where((b) => !b.isUpcoming).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool hasConflict({
    required DateTime date,
    required TimeOfDay start,
    required TimeOfDay end,
    required String roomId,
  }) {
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;

    for (final b in _bookings) {
      if (b.roomId == roomId &&
          b.date.year == date.year &&
          b.date.month == date.month &&
          b.date.day == date.day &&
          b.status != BookingStatus.rejected) {
        final bStart = b.startTime.hour * 60 + b.startTime.minute;
        final bEnd = b.endTime.hour * 60 + b.endTime.minute;
        if (startMin < bEnd && endMin > bStart) return true;
      }
    }
    return false;
  }

  bool studentAlreadyBookedOnDate(DateTime date) {
    if (_currentStudent == null) return false;
    return _bookings.any((b) =>
        b.studentId == _currentStudent!.id &&
        b.date.year == date.year &&
        b.date.month == date.month &&
        b.date.day == date.day &&
        b.status != BookingStatus.rejected);
  }

  Booking createBooking({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int durationMinutes,
    required String durationLabel,
    required int price,
    required String celebrationType,
    required String notes,
  }) {
    if (_currentStudent == null) throw StateError('No student is logged in');

    final student = _currentStudent!;
    final randomId = 1000 + Random().nextInt(9000);
    final bookingId = 'CCH-${date.year}-$randomId';

    final newBooking = Booking(
      id: bookingId,
      studentId: student.id,
      studentName: student.name,
      studentRegNo: student.regNumber,
      studentBranch: student.branch,
      mentorName: student.mentorName,
      mentorPhone: student.mentorPhone,
      date: date,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      durationLabel: durationLabel,
      price: price,
      roomId: student.gender == Gender.male ? 'room_male_102' : 'room_female_104',
      roomName: student.assignedRoomName,
      celebrationType: celebrationType,
      notes: notes,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      agreedToRules: true,
    );

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  void updateBookingStatus(String bookingId, BookingStatus status, {String? comment}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: status,
        mentorComment: comment ??
            (status == BookingStatus.approved
                ? 'Approved by mentor. Adhere to all campus discipline guidelines.'
                : status == BookingStatus.rejected
                    ? 'Request declined due to hall maintenance / conflict.'
                    : null),
      );
      notifyListeners();
    }
  }

  void markBookingPaid(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1 && _bookings[index].status == BookingStatus.approved) {
      _bookings[index] = _bookings[index].copyWith(isPaid: true);
      notifyListeners();
    }
  }

  List<Booking> getMentorBookings({required String mentorName, required String mentorPhone}) {
    final name = mentorName.trim().toLowerCase();
    final phone = mentorPhone.trim();
    return _bookings.where((b) =>
      b.mentorName.trim().toLowerCase() == name && b.mentorPhone.trim() == phone
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void cancelBooking(String bookingId) {
    _bookings.removeWhere((b) => b.id == bookingId);
    notifyListeners();
  }

  List<TimeSlot> getSlotsForDate(DateTime date) {
    final isHoliday = CollegeConfig.isCollegeHoliday(date);
    final isHosteller = _currentStudent?.studentType == StudentType.hosteller;
    return DummyData.generateSlotsForDate(
      date: date,
      isHoliday: isHoliday,
      isHosteller: isHosteller,
      existingBookings: _bookings,
    );
  }
}
