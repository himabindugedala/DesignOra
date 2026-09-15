import 'package:flutter/material.dart';
import '../models/time_slot.dart';

class DurationOption {
  final int minutes;
  final String label;
  final int price;

  const DurationOption({
    required this.minutes,
    required this.label,
    required this.price,
  });
}

class CollegeConfig {
  static const String appName = 'Campus Celebration Hall';
  static const String tagline = 'Celebrate Together. Respect Campus Time.';

  // College timings
  static const TimeOfDay collegeStartTime = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay collegeEndTime = TimeOfDay(hour: 17, minute: 0);

  // Centralized Pricing
  static const List<DurationOption> durationOptions = [
    DurationOption(minutes: 20, label: '20 Mins (Break Special)', price: 40),
    DurationOption(minutes: 30, label: '30 Minutes', price: 50),
    DurationOption(minutes: 60, label: '1 Hour', price: 90),
    DurationOption(minutes: 90, label: '1.5 Hours', price: 130),
    DurationOption(minutes: 120, label: '2 Hours', price: 160),
  ];

  static int getPriceForMinutes(int minutes) {
    final match = durationOptions.firstWhere(
      (opt) => opt.minutes == minutes,
      orElse: () => const DurationOption(minutes: 60, label: '1 Hour', price: 90),
    );
    return match.price;
  }

  // Branches
  static const List<String> branches = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication Engineering',
    'Electrical & Electronics Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Artificial Intelligence & Data Science',
    'Chemical Engineering',
  ];

  // Celebration Types
  static const List<String> celebrationTypes = [
    'Birthday',
    'Farewell',
    'Achievement',
    'Friends Celebration',
    'Small Gathering',
    'Other',
  ];

  // Configured College Holidays (Dates in YYYY-MM-DD or specific calendar dates)
  // We include realistic upcoming holidays relative to the current year/calendar
  static List<DateTime> getHolidays(int year) {
    return [
      DateTime(year, 1, 26),  // Republic Day
      DateTime(year, 8, 15),  // Independence Day
      DateTime(year, 9, 5),   // Teachers Day Celebrations
      DateTime(year, 9, 15),  // Engineers Day Holiday
      DateTime(year, 9, 21),  // Campus Youth Fest / Cultural Day
      DateTime(year, 10, 2),  // Gandhi Jayanti
      DateTime(year, 10, 24), // Dussehra / Vijayadashami
      DateTime(year, 11, 12), // Deepavali
      DateTime(year, 12, 25), // Christmas
    ];
  }

  static bool isCollegeHoliday(DateTime date) {
    final holidays = getHolidays(date.year);
    return holidays.any((h) =>
        h.year == date.year && h.month == date.month && h.day == date.day);
  }

  static String getHolidayName(DateTime date) {
    if (date.month == 9 && date.day == 15) return "Engineers' Day Holiday";
    if (date.month == 9 && date.day == 21) return 'Campus Cultural Holiday';
    if (date.month == 10 && date.day == 2) return 'Gandhi Jayanti';
    if (date.month == 10 && date.day == 24) return 'Vijayadashami Break';
    if (date.month == 11 && date.day == 12) return 'Diwali Holiday';
    if (date.month == 12 && date.day == 25) return 'Christmas Holiday';
    if (date.month == 1 && date.day == 26) return 'Republic Day';
    if (date.month == 8 && date.day == 15) return 'Independence Day';
    return 'Campus Holiday';
  }

  // Rules text details for Rules Screen
  static const List<Map<String, dynamic>> bookingRules = [
    {
      'title': 'Strict College Timings (9:00 AM – 5:00 PM)',
      'description':
          'Classes and academic sessions run strictly between 9:00 AM and 5:00 PM. No student is permitted to book the celebration hall during active instructional class hours.',
      'icon': Icons.schedule_rounded,
    },
    {
      'title': 'Allowed Booking Windows',
      'description':
          '• Morning Break: 10:40 AM – 11:00 AM (20 mins)\n• Lunch Break: 12:40 PM – 1:40 PM (up to 1 hr)\n• Evening Post-College: 5:00 PM – 10:00 PM (up to 2 hrs)',
      'icon': Icons.timelapse_rounded,
    },
    {
      'title': 'Mandatory Mentor Approval',
      'description':
          'Every reservation request is digitally forwarded to your Branch Mentor / Class Teacher. You must receive mentor sign-off before accessing the room.',
      'icon': Icons.verified_user_rounded,
    },
    {
      'title': 'Gender-Specific Celebration Rooms',
      'description':
          'Rooms are automatically assigned by campus security policies (Block A for Boys, Block B for Girls). Students cannot select or enter the opposite gender room.',
      'icon': Icons.meeting_room_rounded,
    },
    {
      'title': 'Hosteller Holiday Special Access',
      'description':
          'Hostel residents are granted full-day booking rights (9:00 AM to 10:00 PM) on configured college holidays and institutional breaks.',
      'icon': Icons.hotel_rounded,
    },
    {
      'title': 'Duration Fit Rule',
      'description':
          'Your chosen booking duration must fit completely inside the selected allowed break/evening window without spilling into class hours.',
      'icon': Icons.timer_outlined,
    },
    {
      'title': 'Zero Overlap & Fair Booking',
      'description':
          'Double-booking of slots is blocked. Only one booking per student per day is allowed to ensure fair campus-wide availability.',
      'icon': Icons.event_busy_rounded,
    },
    {
      'title': 'Hall Cleanliness & Decorum',
      'description':
          'Party poppers, firecrackers, and hazardous materials are strictly prohibited. The room must be handed over in a clean state within 5 minutes of slot conclusion.',
      'icon': Icons.cleaning_services_rounded,
    },
  ];

  // Helper to validate whether a slot duration fits in the period
  static bool durationFitsPeriod(SlotPeriod period, int durationMinutes) {
    return durationMinutes <= period.maxMinutes;
  }

  // Returns duration options applicable to a given period
  static List<DurationOption> getValidDurations(SlotPeriod period) {
    return durationOptions
        .where((opt) => opt.minutes <= period.maxMinutes)
        .toList();
  }
}
