import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  approved,
  rejected,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Approval';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B); // Amber
      case BookingStatus.approved:
        return const Color(0xFF10B981); // Green
      case BookingStatus.rejected:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFFEF3C7);
      case BookingStatus.approved:
        return const Color(0xFFD1FAE5);
      case BookingStatus.rejected:
        return const Color(0xFFFEE2E2);
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_top_rounded;
      case BookingStatus.approved:
        return Icons.check_circle_rounded;
      case BookingStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class Booking {
  final String id;
  final String studentId;
  final String studentName;
  final String studentRegNo;
  final String studentBranch;
  final String mentorName;
  final String mentorPhone;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int durationMinutes;
  final String durationLabel;
  final int price;
  final String roomId;
  final String roomName;
  final String celebrationType;
  final String notes;
  final BookingStatus status;
  final DateTime createdAt;
  final bool agreedToRules;
  final String? mentorComment;
  final bool isPaid;

  const Booking({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentRegNo,
    required this.studentBranch,
    required this.mentorName,
    required this.mentorPhone,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.durationLabel,
    required this.price,
    required this.roomId,
    required this.roomName,
    required this.celebrationType,
    required this.notes,
    required this.status,
    required this.createdAt,
    this.agreedToRules = true,
    this.mentorComment,
    this.isPaid = false,
  });

  bool get isUpcoming {
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
    return bookingDateTime.isAfter(now);
  }

  Booking copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentRegNo,
    String? studentBranch,
    String? mentorName,
    String? mentorPhone,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? durationMinutes,
    String? durationLabel,
    int? price,
    String? roomId,
    String? roomName,
    String? celebrationType,
    String? notes,
    BookingStatus? status,
    DateTime? createdAt,
    bool? agreedToRules,
    String? mentorComment,
    bool? isPaid,
  }) {
    return Booking(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentRegNo: studentRegNo ?? this.studentRegNo,
      studentBranch: studentBranch ?? this.studentBranch,
      mentorName: mentorName ?? this.mentorName,
      mentorPhone: mentorPhone ?? this.mentorPhone,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationLabel: durationLabel ?? this.durationLabel,
      price: price ?? this.price,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      celebrationType: celebrationType ?? this.celebrationType,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      agreedToRules: agreedToRules ?? this.agreedToRules,
      mentorComment: mentorComment ?? this.mentorComment,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
