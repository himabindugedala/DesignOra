import 'package:flutter/material.dart';
import '../models/student.dart';
import 'login_screen.dart';
import 'main_navigation_shell.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class RegistrationApprovalScreen extends StatelessWidget {
  final Student student;

  const RegistrationApprovalScreen({
    super.key,
    required this.student,
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
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              prefillRegNumber: student.regNumber,
              prefillPhone: student.phone,
            ),
          ),
          (route) => false,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Icon / Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(isDark ? 40 : 25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withAlpha(100),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      size: 46,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Registration Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Waiting for Mentor Approval Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(isDark ? 40 : 20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withAlpha(80),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending_actions_rounded,
                          color: Color(0xFFF59E0B), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Waiting for Mentor Approval',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Your profile has been saved in the campus system and notified to your Class Teacher/Mentor (${student.mentorName}).',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Student Details Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 30 : 8),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _row(context, 'Full Name', student.name, isDark),
                      const Divider(height: 20),
                      _row(context, 'Registration No.', student.regNumber, isDark),
                      const Divider(height: 20),
                      _row(context, 'Department', student.branch, isDark),
                      const Divider(height: 20),
                      _row(context, 'Phone Number', student.phone, isDark),
                      const Divider(height: 20),
                      _row(context, 'Gender', student.genderDisplay, isDark),
                      const Divider(height: 20),
                      _row(context, 'Class Teacher / Mentor', student.mentorName, isDark),
                      const Divider(height: 20),
                      _row(
                        context,
                        'Assigned Room',
                        student.assignedRoomName,
                        isDark,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Local demo action: simulate mentor approval without a backend.
                ElevatedButton.icon(
                  onPressed: () async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    await appState.approveStudent(student.id);
                    await appState.login(
                      regNumber: student.regNumber,
                      phone: student.phone,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Demo: Mentor Approves'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          prefillRegNumber: student.regNumber,
                          prefillPhone: student.phone,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Back to Login'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value,
    bool isDark, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ],
    );
  }
}
