import 'package:flutter/material.dart';
import '../models/booking.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    IconData icon;
    String label = status.displayName;

    switch (status) {
      case BookingStatus.pending:
        bg = isDark
            ? const Color(0xFF78350F).withAlpha(100)
            : const Color(0xFFFEF3C7);
        fg = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
        icon = Icons.hourglass_top_rounded;
        break;
      case BookingStatus.approved:
        bg = isDark
            ? const Color(0xFF064E3B).withAlpha(100)
            : const Color(0xFFD1FAE5);
        fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
        icon = Icons.check_circle_rounded;
        break;
      case BookingStatus.rejected:
        bg = isDark
            ? const Color(0xFF7F1D1D).withAlpha(100)
            : const Color(0xFFFEE2E2);
        fg = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        break;
    }

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
