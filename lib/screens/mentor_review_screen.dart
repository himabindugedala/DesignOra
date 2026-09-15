import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/app_state.dart';
import '../utils/date_utils.dart';

class MentorReviewScreen extends StatelessWidget {
  final String bookingId;

  const MentorReviewScreen({super.key, required this.bookingId});

  void _update(BuildContext context, AppState appState, Booking booking, BookingStatus status) {
    final comment = status == BookingStatus.approved
        ? 'Approved by ${booking.mentorName}. Booking is cleared after mentor verification.'
        : 'Rejected by ${booking.mentorName}. Please contact your mentor for clarification.';
    appState.updateBookingStatus(booking.id, status, comment: comment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final matches = appState.bookings.where((b) => b.id == bookingId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mentor Review')),
        body: const Center(child: Text('Booking request not found.')),
      );
    }
    final booking = matches.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Review')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Designated Branch Mentor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(booking.mentorName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Mentor phone: ${booking.mentorPhone}'),
                const Divider(height: 28),
                Text('Student: ${booking.studentName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text('${booking.studentRegNo} • ${booking.studentBranch}'),
                const SizedBox(height: 18),
                _row('Celebration', booking.celebrationType),
                _row('Date', AppDateUtils.formatDate(booking.date)),
                _row('Time', '${booking.startTime.format(context)} - ${booking.endTime.format(context)}'),
                _row('Room', booking.roomName),
                _row('Duration', booking.durationLabel),
                _row('Fee', '₹${booking.price}'),
                if (booking.notes.isNotEmpty) _row('Purpose', booking.notes),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withAlpha(18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withAlpha(60)),
            ),
            child: const Text(
              'Only the designated mentor for this student request should approve or reject it. This screen is a local prototype simulation; no real mentor account/backend is connected.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _update(context, appState, booking, BookingStatus.approved),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Approve Booking'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _update(context, appState, booking, BookingStatus.rejected),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject Booking'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Approval Status'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 95, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}
