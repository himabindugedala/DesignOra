import 'package:flutter/material.dart';
import '../models/time_slot.dart';

class TimingCard extends StatelessWidget {
  final SlotPeriod period;
  final VoidCallback? onTap;

  const TimingCard({
    super.key,
    required this.period,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;
    Color color;
    String badgeText;

    switch (period) {
      case SlotPeriod.morningBreak:
        icon = Icons.wb_twilight_rounded;
        color = const Color(0xFFF59E0B); // Amber
        badgeText = '20 mins max';
        break;
      case SlotPeriod.lunchBreak:
        icon = Icons.lunch_dining_rounded;
        color = const Color(0xFF06B6D4); // Cyan
        badgeText = 'Up to 1 hr';
        break;
      case SlotPeriod.evening:
        icon = Icons.nightlight_round;
        color = const Color(0xFF6366F1); // Indigo
        badgeText = 'Up to 2 hrs';
        break;
      case SlotPeriod.holidayFullDay:
        icon = Icons.celebration_rounded;
        color = const Color(0xFFEC4899); // Pink
        badgeText = 'Hosteller Special';
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 50 : 25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 40 : 20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              period.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              period.timingDescription,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
