import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';

class DummyData {
  static final Student defaultStudent = Student(
    id: 'std_2026_01',
    name: 'Rahul Sharma',
    regNumber: '22BCE1084',
    branch: 'Computer Science & Engineering',
    phone: '9876543210',
    mentorName: 'Dr. K. Ramesh',
    mentorPhone: '9845012345',
    gender: Gender.male,
    studentType: StudentType.hosteller,
  );

  static final Student femaleDemoStudent = Student(
    id: 'std_2026_02',
    name: 'Ananya Verma',
    regNumber: '22BCE1142',
    branch: 'Artificial Intelligence & Data Science',
    phone: '9898981234',
    mentorName: 'Prof. S. Mythili',
    mentorPhone: '9443219876',
    gender: Gender.female,
    studentType: StudentType.dayScholar,
  );

  static List<Booking> getInitialBookings() {
    final now = DateTime.now();

    return [
      // 1. Pending booking (Demonstrates Pending status & approval timeline)
      Booking(
        id: 'CCH-2026-9041',
        studentId: defaultStudent.id,
        studentName: defaultStudent.name,
        studentRegNo: defaultStudent.regNumber,
        studentBranch: defaultStudent.branch,
        mentorName: defaultStudent.mentorName,
        mentorPhone: defaultStudent.mentorPhone,
        date: now.add(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 17, minute: 30),
        endTime: const TimeOfDay(hour: 18, minute: 30),
        durationMinutes: 60,
        durationLabel: '1 Hour',
        price: 90,
        roomId: 'room_male_102',
        roomName: 'Male Celebration Room',
        celebrationType: 'Birthday',
        notes: 'Celebrating roommate Rohan’s 20th birthday with our branch group.',
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
        agreedToRules: true,
      ),

      // 2. Approved booking (Demonstrates Approved status & Confirmed state)
      Booking(
        id: 'CCH-2026-8815',
        studentId: defaultStudent.id,
        studentName: defaultStudent.name,
        studentRegNo: defaultStudent.regNumber,
        studentBranch: defaultStudent.branch,
        mentorName: defaultStudent.mentorName,
        mentorPhone: defaultStudent.mentorPhone,
        date: now.add(const Duration(days: 3)),
        startTime: const TimeOfDay(hour: 12, minute: 40),
        endTime: const TimeOfDay(hour: 13, minute: 40),
        durationMinutes: 60,
        durationLabel: '1 Hour',
        price: 90,
        roomId: 'room_male_102',
        roomName: 'Male Celebration Room',
        celebrationType: 'Achievement',
        notes: 'Smart India Hackathon national finalist qualification celebration.',
        status: BookingStatus.approved,
        createdAt: now.subtract(const Duration(days: 1)),
        agreedToRules: true,
        mentorComment:
            'Approved. Congratulations on qualifying for SIH Finals! Keep noise level moderate.',
      ),

      // 3. Rejected booking (Demonstrates Rejected status with mentor note)
      Booking(
        id: 'CCH-2026-7920',
        studentId: defaultStudent.id,
        studentName: defaultStudent.name,
        studentRegNo: defaultStudent.regNumber,
        studentBranch: defaultStudent.branch,
        mentorName: defaultStudent.mentorName,
        mentorPhone: defaultStudent.mentorPhone,
        date: now.subtract(const Duration(days: 2)),
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        durationMinutes: 120,
        durationLabel: '2 Hours',
        price: 160,
        roomId: 'room_male_102',
        roomName: 'Male Celebration Room',
        celebrationType: 'Friends Celebration',
        notes: 'Semester end celebration with batchmates.',
        status: BookingStatus.rejected,
        createdAt: now.subtract(const Duration(days: 3)),
        agreedToRules: true,
        mentorComment:
            'Rejected. Hall reserved for department faculty meeting during this period.',
      ),

      // 4. Past Completed booking
      Booking(
        id: 'CCH-2026-6540',
        studentId: defaultStudent.id,
        studentName: defaultStudent.name,
        studentRegNo: defaultStudent.regNumber,
        studentBranch: defaultStudent.branch,
        mentorName: defaultStudent.mentorName,
        mentorPhone: defaultStudent.mentorPhone,
        date: now.subtract(const Duration(days: 10)),
        startTime: const TimeOfDay(hour: 10, minute: 40),
        endTime: const TimeOfDay(hour: 11, minute: 0),
        durationMinutes: 20,
        durationLabel: '20 Mins (Break Special)',
        price: 40,
        roomId: 'room_male_102',
        roomName: 'Male Celebration Room',
        celebrationType: 'Farewell',
        notes: 'Quick farewell to senior mentor before placement drive.',
        status: BookingStatus.approved,
        createdAt: now.subtract(const Duration(days: 11)),
        agreedToRules: true,
        mentorComment: 'Approved by Dr. K. Ramesh.',
      ),
    ];
  }

  // Pre-configured slots generated for a date
  static List<TimeSlot> generateSlotsForDate({
    required DateTime date,
    required bool isHoliday,
    required bool isHosteller,
    required List<Booking> existingBookings,
  }) {
    final List<TimeSlot> slots = [];

    // Check if this date has any existing booked times
    bool isTimeBooked(TimeOfDay start, TimeOfDay end) {
      final startMin = start.hour * 60 + start.minute;
      final endMin = end.hour * 60 + end.minute;

      for (final b in existingBookings) {
        if (b.date.year == date.year &&
            b.date.month == date.month &&
            b.date.day == date.day &&
            b.status != BookingStatus.rejected) {
          final bStart = b.startTime.hour * 60 + b.startTime.minute;
          final bEnd = b.endTime.hour * 60 + b.endTime.minute;

          // Check overlap
          if (startMin < bEnd && endMin > bStart) {
            return true;
          }
        }
      }
      return false;
    }

    // 1. Morning Break: 10:40 AM - 11:00 AM
    slots.add(TimeSlot(
      id: 'slot_morning_1',
      startTime: const TimeOfDay(hour: 10, minute: 40),
      endTime: const TimeOfDay(hour: 11, minute: 0),
      period: SlotPeriod.morningBreak,
      isBooked: isTimeBooked(
        const TimeOfDay(hour: 10, minute: 40),
        const TimeOfDay(hour: 11, minute: 0),
      ),
    ));

    // 2. Lunch Break: 12:40 PM - 1:40 PM (30 min or 60 min slots)
    slots.add(TimeSlot(
      id: 'slot_lunch_full',
      startTime: const TimeOfDay(hour: 12, minute: 40),
      endTime: const TimeOfDay(hour: 13, minute: 40),
      period: SlotPeriod.lunchBreak,
      isBooked: isTimeBooked(
        const TimeOfDay(hour: 12, minute: 40),
        const TimeOfDay(hour: 13, minute: 40),
      ),
    ));

    slots.add(TimeSlot(
      id: 'slot_lunch_half1',
      startTime: const TimeOfDay(hour: 12, minute: 40),
      endTime: const TimeOfDay(hour: 13, minute: 10),
      period: SlotPeriod.lunchBreak,
      isBooked: isTimeBooked(
        const TimeOfDay(hour: 12, minute: 40),
        const TimeOfDay(hour: 13, minute: 10),
      ),
    ));

    slots.add(TimeSlot(
      id: 'slot_lunch_half2',
      startTime: const TimeOfDay(hour: 13, minute: 10),
      endTime: const TimeOfDay(hour: 13, minute: 40),
      period: SlotPeriod.lunchBreak,
      isBooked: isTimeBooked(
        const TimeOfDay(hour: 13, minute: 10),
        const TimeOfDay(hour: 13, minute: 40),
      ),
    ));

    // 3. Evening (5:00 PM - 10:00 PM)
    final eveningStartHours = [
      {'h': 17, 'm': 0, 'dur': 60},
      {'h': 17, 'm': 30, 'dur': 60},
      {'h': 18, 'm': 0, 'dur': 90},
      {'h': 18, 'm': 30, 'dur': 60},
      {'h': 19, 'm': 0, 'dur': 120},
      {'h': 19, 'm': 30, 'dur': 60},
      {'h': 20, 'm': 0, 'dur': 60},
      {'h': 20, 'm': 30, 'dur': 60},
      {'h': 21, 'm': 0, 'dur': 60},
    ];

    for (int i = 0; i < eveningStartHours.length; i++) {
      final item = eveningStartHours[i];
      final start = TimeOfDay(hour: item['h'] as int, minute: item['m'] as int);
      final totalMinutes = start.hour * 60 + start.minute + (item['dur'] as int);
      final end = TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);

      slots.add(TimeSlot(
        id: 'slot_evening_$i',
        startTime: start,
        endTime: end,
        period: SlotPeriod.evening,
        isBooked: isTimeBooked(start, end),
      ));
    }

    // 4. Holiday Full Day slots if holiday and hosteller
    if (isHoliday && isHosteller) {
      final holidaySlots = [
        {'h': 9, 'm': 30, 'dur': 60},
        {'h': 11, 'm': 0, 'dur': 90},
        {'h': 14, 'm': 0, 'dur': 120},
        {'h': 16, 'm': 0, 'dur': 60},
      ];
      for (int i = 0; i < holidaySlots.length; i++) {
        final item = holidaySlots[i];
        final start = TimeOfDay(hour: item['h'] as int, minute: item['m'] as int);
        final totalMinutes =
            start.hour * 60 + start.minute + (item['dur'] as int);
        final end = TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);

        slots.add(TimeSlot(
          id: 'slot_holiday_$i',
          startTime: start,
          endTime: end,
          period: SlotPeriod.holidayFullDay,
          isBooked: isTimeBooked(start, end),
        ));
      }
    }

    return slots;
  }
}
