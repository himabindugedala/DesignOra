import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_celebration_hall/models/student.dart';
import 'package:campus_celebration_hall/models/booking.dart';
import 'package:campus_celebration_hall/models/time_slot.dart';
import 'package:campus_celebration_hall/data/college_config.dart';
import 'package:campus_celebration_hall/services/app_state.dart';

void main() {
  group('Campus Celebration Hall - Core Logic & Rules Tests', () {
    test('1. Strict Gender Room Auto-assignment', () {
      final maleStudent = Student(
        id: '1',
        name: 'Rahul',
        regNumber: '22BCE1084',
        branch: 'CSE',
        phone: '9876543210',
        mentorName: 'Dr. Ramesh',
        mentorPhone: '9845012345',
        gender: Gender.male,
        studentType: StudentType.hosteller,
      );

      final femaleStudent = Student(
        id: '2',
        name: 'Ananya',
        regNumber: '22BCE1142',
        branch: 'AI & DS',
        phone: '9898981234',
        mentorName: 'Prof. Mythili',
        mentorPhone: '9443219876',
        gender: Gender.female,
        studentType: StudentType.dayScholar,
      );

      expect(maleStudent.assignedRoomName, equals('Male Celebration Room'));
      expect(femaleStudent.assignedRoomName, equals('Female Celebration Room'));
    });

    test('2. Centralized Pricing Rules', () {
      // 30 mins -> ₹50
      expect(CollegeConfig.getPriceForMinutes(30), equals(50));
      // 1 hour (60 mins) -> ₹90
      expect(CollegeConfig.getPriceForMinutes(60), equals(90));
      // 1.5 hours (90 mins) -> ₹130
      expect(CollegeConfig.getPriceForMinutes(90), equals(130));
      // 2 hours (120 mins) -> ₹160
      expect(CollegeConfig.getPriceForMinutes(120), equals(160));
    });

    test('3. Duration Fit in Allowed Periods', () {
      // Morning Break is 20 mins max -> 30 mins, 60 mins cannot fit
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.morningBreak, 20), isTrue);
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.morningBreak, 30), isFalse);
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.morningBreak, 60), isFalse);

      // Lunch Break is 60 mins max -> 30 and 60 fit, 90 mins does not fit
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.lunchBreak, 30), isTrue);
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.lunchBreak, 60), isTrue);
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.lunchBreak, 90), isFalse);

      // Evening is 300 mins max (5 PM - 10 PM) -> 120 mins fits
      expect(CollegeConfig.durationFitsPeriod(SlotPeriod.evening, 120), isTrue);
    });

    test('4. College Holiday Detection & Hosteller Full Day', () {
      final holiday = DateTime(2026, 9, 15); // Engineer's Day
      final regularDay = DateTime(2026, 9, 16);

      expect(CollegeConfig.isCollegeHoliday(holiday), isTrue);
      expect(CollegeConfig.isCollegeHoliday(regularDay), isFalse);
    });

    test('5. Booking Creation and Status Simulation', () async {
      final appState = AppState();
      final testStudent = Student(
        id: 'test_student',
        name: 'Test Student',
        regNumber: 'TEST001',
        branch: 'Computer Science & Engineering',
        phone: '9876543210',
        mentorName: 'Test Mentor',
        mentorPhone: '9876543211',
        gender: Gender.male,
        studentType: StudentType.hosteller,
        isApproved: true,
      );
      await appState.registerStudent(testStudent);
      await appState.login(regNumber: 'TEST001', phone: '9876543210');
      final initialCount = appState.bookings.length;

      final testDate = DateTime(2026, 10, 15);
      final booking = appState.createBooking(
        date: testDate,
        startTime: const TimeOfDay(hour: 17, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
        durationMinutes: 60,
        durationLabel: '1 Hour',
        price: 90,
        celebrationType: 'Birthday',
        notes: 'Test Birthday Booking',
      );

      // Must start in Pending state
      expect(booking.status, equals(BookingStatus.pending));
      expect(appState.bookings.length, equals(initialCount + 1));

      // Cannot book twice on the same day (fair usage rule)
      expect(appState.studentAlreadyBookedOnDate(testDate), isTrue);

      // Simulate Mentor Approval
      appState.updateBookingStatus(booking.id, BookingStatus.approved);
      final updatedBooking =
          appState.bookings.firstWhere((b) => b.id == booking.id);
      expect(updatedBooking.status, equals(BookingStatus.approved));
    });
  });
}
