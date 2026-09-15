import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/app_state.dart';
import '../utils/date_utils.dart';
import '../widgets/status_badge.dart';
import '../widgets/timeline_widget.dart';
import 'payment_screen.dart';

class ApprovalStatusScreen extends StatelessWidget {
  final String bookingId;

  const ApprovalStatusScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);

    // Find booking
    final booking = appState.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => appState.bookings.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Approval Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Header Card with Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: booking.status.color.withAlpha(isDark ? 100 : 50),
              ),
              boxShadow: [
                BoxShadow(
                  color: booking.status.color.withAlpha(isDark ? 30 : 15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.id,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
                const SizedBox(height: 4),
                Text(
                  '${AppDateUtils.formatDate(booking.date)} • ${booking.startTime.format(context)} to ${booking.endTime.format(context)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Mentor Comment / Note banner
                if (booking.mentorComment != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: booking.status == BookingStatus.approved
                          ? const Color(0xFF10B981).withAlpha(isDark ? 35 : 15)
                          : const Color(0xFFEF4444).withAlpha(isDark ? 35 : 15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: booking.status == BookingStatus.approved
                            ? const Color(0xFF10B981).withAlpha(50)
                            : const Color(0xFFEF4444).withAlpha(50),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          booking.status == BookingStatus.approved
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: booking.status.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mentor Feedback (${booking.mentorName}):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: booking.status.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking.mentorComment!,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.3,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Approval Timeline Widget
          ApprovalTimelineWidget(booking: booking),
          const SizedBox(height: 24),

          // Digital Entry Pass (Only when Approved)
          if (booking.status == BookingStatus.approved && booking.isPaid) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                      : [const Color(0xFFD1FAE5), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF10B981).withAlpha(isDark ? 100 : 50),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Color(0xFF10B981),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Authorized Campus Pass',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Present to Security Desk at Hall Entrance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ROOM ACCESS CODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'CCH-${booking.studentRegNo.replaceAll(RegExp(r'\D'), '')}-PASS',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Student only sees the assigned mentor and current status.
          // Approve/Reject actions are available only from Mentor Dashboard.
          if (booking.status == BookingStatus.pending) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Waiting for ${booking.mentorName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Assigned mentor: ${booking.mentorName}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Mentor phone: ${booking.mentorPhone}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text('Your mentor will review this request and either approve or reject it.', style: TextStyle(fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (booking.status == BookingStatus.approved && !booking.isPaid) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(isDark ? 25 : 12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Approved 🎉', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Approved by ${booking.mentorName}. Payment is required to confirm the booking.', style: const TextStyle(fontSize: 12, height: 1.4)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking))),
                      icon: const Icon(Icons.payment_rounded),
                      label: Text('Proceed to Payment • ₹${booking.price}'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (booking.status == BookingStatus.approved && booking.isPaid) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(isDark ? 25 : 12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
              ),
              child: const Text('Payment completed. Your booking is confirmed and the campus pass is active.', style: TextStyle(fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Booking Details'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
