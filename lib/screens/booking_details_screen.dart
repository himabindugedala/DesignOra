import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/app_state.dart';
import '../utils/date_utils.dart';
import '../widgets/status_badge.dart';
import 'approval_status_screen.dart';
import 'booking_rules_screen.dart';
import 'payment_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  void _confirmCancelBooking(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: const Text(
          'Are you sure you want to cancel this celebration request? This will free the slot for other students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Slot'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              appState.cancelBooking(bookingId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);

    // Find booking
    final matches = appState.bookings.where((b) => b.id == bookingId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Booking no longer available')),
      );
    }
    final booking = matches.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Booking Rules',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookingRulesScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.id,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    StatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  booking.celebrationType,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.roomName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Reservation Details Table Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _detailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  val: AppDateUtils.formatDate(booking.date),
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _detailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time Interval',
                  val:
                      '${booking.startTime.format(context)} - ${booking.endTime.format(context)}',
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _detailRow(
                  icon: Icons.timelapse_rounded,
                  label: 'Duration',
                  val: booking.durationLabel,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _detailRow(
                  icon: Icons.payments_outlined,
                  label: 'Booking Fee',
                  val: '₹${booking.price}',
                  valColor: theme.colorScheme.primary,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _detailRow(
                  icon: Icons.notes_rounded,
                  label: 'Notes / Purpose',
                  val: booking.notes,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mentor & Faculty Information Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faculty Mentor Verification',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _detailRow(
                  icon: Icons.person_pin_rounded,
                  label: 'Designated Mentor',
                  val: booking.mentorName,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _detailRow(
                  icon: Icons.phone_rounded,
                  label: 'Mentor Phone',
                  val: booking.mentorPhone,
                  isDark: isDark,
                ),
                if (booking.mentorComment != null) ...[
                  const Divider(height: 20),
                  _detailRow(
                    icon: Icons.comment_rounded,
                    label: 'Mentor Comment',
                    val: booking.mentorComment!,
                    valColor: booking.status.color,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (booking.status == BookingStatus.approved && !booking.isPaid) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)),
                ),
                icon: const Icon(Icons.payment_rounded),
                label: Text('Pay Booking Fee • ₹${booking.price}'),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Track Approval Status Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ApprovalStatusScreen(bookingId: booking.id),
                ),
              );
            },
            icon: const Icon(Icons.timeline_rounded),
            label: const Text('View Approval Timeline & Status'),
          ),
          const SizedBox(height: 12),

          // Cancel Reservation Button (if pending)
          if (booking.status == BookingStatus.pending)
            OutlinedButton.icon(
              onPressed: () => _confirmCancelBooking(context, appState),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Celebration Request'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String val,
    required bool isDark,
    Color? valColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valColor ??
                  (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ],
    );
  }
}
