import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/time_slot.dart';
import '../data/college_config.dart';
import '../services/app_state.dart';
import '../utils/date_utils.dart';
import 'confirmation_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DurationOption duration;
  final SlotPeriod period;

  const BookingFormScreen({
    super.key,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.period,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late String _selectedCelebrationType;
  bool _agreedToRules = false;

  @override
  void initState() {
    super.initState();
    _selectedCelebrationType = CollegeConfig.celebrationTypes.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(Student student) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please check and agree to follow campus celebration rules.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.send_rounded, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Confirm Submission'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your celebration hall reservation request will be dispatched to your mentor for academic verification:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _dialogRow('Mentor', student.mentorName),
                  const SizedBox(height: 6),
                  _dialogRow('Date', AppDateUtils.formatDate(widget.date)),
                  const SizedBox(height: 6),
                  _dialogRow('Time',
                      '${widget.startTime.format(context)} - ${widget.endTime.format(context)}'),
                  const SizedBox(height: 6),
                  _dialogRow('Type', _selectedCelebrationType),
                  const SizedBox(height: 6),
                  _dialogRow('Fee', '₹${widget.duration.price}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Review Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitBooking();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 42),
            ),
            child: const Text('Send to Mentor'),
          ),
        ],
      ),
    );
  }

  void _submitBooking() {
    final appState = Provider.of<AppState>(context, listen: false);

    final newBooking = appState.createBooking(
      date: widget.date,
      startTime: widget.startTime,
      endTime: widget.endTime,
      durationMinutes: widget.duration.minutes,
      durationLabel: widget.duration.label,
      price: widget.duration.price,
      celebrationType: _selectedCelebrationType,
      notes: _notesController.text.trim().isEmpty
          ? 'No additional notes specified.'
          : _notesController.text.trim(),
    );

    // Navigate to ConfirmationScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(booking: newBooking),
      ),
    );
  }

  Widget _dialogRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          val,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);
    final student = appState.currentStudent;

    if (student == null) {
      return const Scaffold(
        body: Center(child: Text('Student profile not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Celebration Booking Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Auto-filled Student Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              theme.colorScheme.primary.withAlpha(30),
                          child: Text(
                            student.name[0],
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${student.regNumber} • ${student.branch}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Auto-filled',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.supervisor_account_rounded,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Reviewing Mentor: ${student.mentorName} (${student.mentorPhone})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Booking Slot & Venue Summary Card
              Text(
                'Selected Slot & Venue',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFEEF2FF), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 80 : 40),
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: AppDateUtils.formatDate(widget.date),
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      context,
                      icon: Icons.access_time_rounded,
                      label: 'Time Window',
                      value:
                          '${widget.startTime.format(context)} - ${widget.endTime.format(context)}',
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      context,
                      icon: Icons.timelapse_rounded,
                      label: 'Duration',
                      value: widget.duration.label,
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      context,
                      icon: Icons.meeting_room_rounded,
                      label: 'Assigned Room',
                      value: student.assignedRoomName,
                      valueColor: theme.colorScheme.primary,
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calculated Slot Price',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${widget.duration.price}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Celebration Type Selection
              Text(
                'Celebration Type *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CollegeConfig.celebrationTypes.map((type) {
                  final isSelected = _selectedCelebrationType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCelebrationType = type);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Notes / Reason
              Text(
                'Celebration Purpose & Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Birthday celebration with CSE department friends. Cake cutting & light refreshments.',
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please briefly describe the celebration for mentor review';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 5. Checkbox: Agreement to Rules
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _agreedToRules
                        ? theme.colorScheme.primary.withAlpha(120)
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToRules,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setState(() => _agreedToRules = val ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _agreedToRules = !_agreedToRules);
                        },
                        child: Text(
                          '“I agree to follow all campus celebration rules, maintain volume decorum, and keep the hall clean.”',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 6. Submit Button
              ElevatedButton.icon(
                onPressed: () => _showConfirmationDialog(student),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Send for Mentor Approval'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
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
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
