import 'package:flutter/material.dart';

enum SlotPeriod {
  morningBreak,
  lunchBreak,
  evening,
  holidayFullDay,
}

extension SlotPeriodExtension on SlotPeriod {
  String get title {
    switch (this) {
      case SlotPeriod.morningBreak:
        return 'Morning Break';
      case SlotPeriod.lunchBreak:
        return 'Lunch Break';
      case SlotPeriod.evening:
        return 'Evening (Post-College)';
      case SlotPeriod.holidayFullDay:
        return 'Holiday Special';
    }
  }

  String get timingDescription {
    switch (this) {
      case SlotPeriod.morningBreak:
        return '10:40 AM – 11:00 AM';
      case SlotPeriod.lunchBreak:
        return '12:40 PM – 1:40 PM';
      case SlotPeriod.evening:
        return '5:00 PM – 10:00 PM';
      case SlotPeriod.holidayFullDay:
        return '9:00 AM – 10:00 PM';
    }
  }

  TimeOfDay get periodStart {
    switch (this) {
      case SlotPeriod.morningBreak:
        return const TimeOfDay(hour: 10, minute: 40);
      case SlotPeriod.lunchBreak:
        return const TimeOfDay(hour: 12, minute: 40);
      case SlotPeriod.evening:
        return const TimeOfDay(hour: 17, minute: 0);
      case SlotPeriod.holidayFullDay:
        return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  TimeOfDay get periodEnd {
    switch (this) {
      case SlotPeriod.morningBreak:
        return const TimeOfDay(hour: 11, minute: 0);
      case SlotPeriod.lunchBreak:
        return const TimeOfDay(hour: 13, minute: 40);
      case SlotPeriod.evening:
        return const TimeOfDay(hour: 22, minute: 0);
      case SlotPeriod.holidayFullDay:
        return const TimeOfDay(hour: 22, minute: 0);
    }
  }

  int get maxMinutes {
    switch (this) {
      case SlotPeriod.morningBreak:
        return 20;
      case SlotPeriod.lunchBreak:
        return 60;
      case SlotPeriod.evening:
        return 300;
      case SlotPeriod.holidayFullDay:
        return 780;
    }
  }
}

class TimeSlot {
  final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final SlotPeriod period;
  final bool isBooked;

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.period,
    this.isBooked = false,
  });

  String format(BuildContext context) {
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }

  int get durationMinutes {
    final startMin = startTime.hour * 60 + startTime.minute;
    final endMin = endTime.hour * 60 + endTime.minute;
    return endMin - startMin;
  }

  TimeSlot copyWith({
    String? id,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    SlotPeriod? period,
    bool? isBooked,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      period: period ?? this.period,
      isBooked: isBooked ?? this.isBooked,
    );
  }
}
