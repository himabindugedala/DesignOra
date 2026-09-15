import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../utils/date_utils.dart';
import '../widgets/status_badge.dart';
import 'approval_status_screen.dart';
import 'main_navigation_shell.dart';

class ConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const ConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Success Animated Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(isDark ? 40 : 25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981).withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Request Sent!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  '“Your celebration booking request has been sent to your mentor for approval.”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),

                // Booking Receipt / Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 40 : 10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Row: Booking ID + Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BOOKING ID',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                booking.id,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(status: booking.status),
                        ],
                      ),
                      const Divider(height: 26),

                      // Details List
                      _receiptItem(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: AppDateUtils.formatDate(booking.date),
                      ),
                      const SizedBox(height: 12),
                      _receiptItem(
                        context,
                        icon: Icons.access_time_rounded,
                        label: 'Time Slot',
                        value:
                            '${booking.startTime.format(context)} - ${booking.endTime.format(context)}',
                      ),
                      const SizedBox(height: 12),
                      _receiptItem(
                        context,
                        icon: Icons.timelapse_rounded,
                        label: 'Duration',
                        value: booking.durationLabel,
                      ),
                      const SizedBox(height: 12),
                      _receiptItem(
                        context,
                        icon: Icons.meeting_room_rounded,
                        label: 'Assigned Room',
                        value: booking.roomName,
                      ),
                      const SizedBox(height: 12),
                      _receiptItem(
                        context,
                        icon: Icons.supervisor_account_rounded,
                        label: 'Branch Mentor',
                        value: booking.mentorName,
                      ),
                      const SizedBox(height: 12),
                      _receiptItem(
                        context,
                        icon: Icons.celebration_rounded,
                        label: 'Celebration',
                        value: booking.celebrationType,
                      ),
                      const Divider(height: 26),

                      // Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Slot Fee (Pay after mentor approval)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${booking.price}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Button 1: Track Approval Status
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ApprovalStatusScreen(bookingId: booking.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timeline_rounded),
                  label: const Text('Track Approval Status'),
                ),
                const SizedBox(height: 14),

                // Button 2: Return to Home
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationShell(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
