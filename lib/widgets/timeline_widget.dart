import 'package:flutter/material.dart';
import '../models/booking.dart';

class TimelineStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isFailed;
  final IconData? customIcon;

  const TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    this.isFailed = false,
    this.customIcon,
  });
}

class ApprovalTimelineWidget extends StatelessWidget {
  final Booking booking;

  const ApprovalTimelineWidget({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = _buildSteps();

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Approval Progress Timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _buildTimelineItem(
              context: context,
              step: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  List<TimelineStep> _buildSteps() {
    final status = booking.status;

    switch (status) {
      case BookingStatus.pending:
        return [
          const TimelineStep(
            title: 'Booking Created',
            subtitle: 'Slot requested & room assigned',
            isCompleted: true,
            isCurrent: false,
          ),
          TimelineStep(
            title: 'Sent to Mentor',
            subtitle: 'Forwarded to ${booking.mentorName}',
            isCompleted: true,
            isCurrent: false,
          ),
          const TimelineStep(
            title: 'Mentor Review',
            subtitle: 'Awaiting mentor verification & decision',
            isCompleted: false,
            isCurrent: true,
            customIcon: Icons.hourglass_top_rounded,
          ),
          const TimelineStep(
            title: 'Booking Confirmed',
            subtitle: 'Digital pass generated upon sign-off',
            isCompleted: false,
            isCurrent: false,
          ),
        ];

      case BookingStatus.approved:
        return [
          const TimelineStep(
            title: 'Booking Created',
            subtitle: 'Slot requested & room assigned',
            isCompleted: true,
            isCurrent: false,
          ),
          TimelineStep(
            title: 'Sent to Mentor',
            subtitle: 'Received by ${booking.mentorName}',
            isCompleted: true,
            isCurrent: false,
          ),
          const TimelineStep(
            title: 'Mentor Approved',
            subtitle: 'Verified without scheduling conflicts',
            isCompleted: true,
            isCurrent: false,
          ),
          const TimelineStep(
            title: 'Booking Confirmed 🎉',
            subtitle: 'Room access granted. Please maintain decorum.',
            isCompleted: true,
            isCurrent: true,
            customIcon: Icons.verified_rounded,
          ),
        ];

      case BookingStatus.rejected:
        return [
          const TimelineStep(
            title: 'Booking Created',
            subtitle: 'Slot requested & room assigned',
            isCompleted: true,
            isCurrent: false,
          ),
          TimelineStep(
            title: 'Sent to Mentor',
            subtitle: 'Forwarded to ${booking.mentorName}',
            isCompleted: true,
            isCurrent: false,
          ),
          const TimelineStep(
            title: 'Mentor Review Finished',
            subtitle: 'Evaluation completed',
            isCompleted: true,
            isCurrent: false,
          ),
          TimelineStep(
            title: 'Request Rejected',
            subtitle: booking.mentorComment ??
                'Declined due to academic scheduling conflict.',
            isCompleted: false,
            isCurrent: true,
            isFailed: true,
            customIcon: Icons.cancel_rounded,
          ),
        ];
    }
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required TimelineStep step,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color nodeColor;
    Color iconColor;
    IconData nodeIcon;

    if (step.isFailed) {
      nodeColor = const Color(0xFFEF4444);
      iconColor = Colors.white;
      nodeIcon = step.customIcon ?? Icons.close_rounded;
    } else if (step.isCompleted) {
      nodeColor = const Color(0xFF10B981);
      iconColor = Colors.white;
      nodeIcon = Icons.check_rounded;
    } else if (step.isCurrent) {
      nodeColor = const Color(0xFFF59E0B);
      iconColor = Colors.white;
      nodeIcon = step.customIcon ?? Icons.hourglass_top_rounded;
    } else {
      nodeColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      iconColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      nodeIcon = Icons.radio_button_unchecked_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Node & Connecting Line
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  boxShadow: (step.isCurrent || step.isCompleted)
                      ? [
                          BoxShadow(
                            color: nodeColor.withAlpha(60),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(nodeIcon, size: 16, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.isCompleted
                        ? const Color(0xFF10B981)
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Right Title & Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: step.isFailed
                          ? const Color(0xFFEF4444)
                          : (step.isCompleted || step.isCurrent)
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
