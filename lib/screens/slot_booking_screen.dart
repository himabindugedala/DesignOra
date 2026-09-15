import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/time_slot.dart';
import '../data/college_config.dart';
import '../services/app_state.dart';
import '../utils/date_utils.dart';
import '../widgets/duration_selector.dart';
import 'booking_form_screen.dart';

class SlotBookingScreen extends StatefulWidget {
  final SlotPeriod? initialPeriod;

  const SlotBookingScreen({
    super.key,
    this.initialPeriod,
  });

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  late DateTime _selectedDate;
  SlotPeriod? _selectedPeriodFilter;
  TimeSlot? _selectedSlot;
  late DurationOption _selectedDuration;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedPeriodFilter = widget.initialPeriod;
    _selectedDuration = CollegeConfig.durationOptions[2]; // Default 1 Hour (₹90)
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSlot = null; // reset slot selection
    });
  }

  void _onPeriodFilterChanged(SlotPeriod? period) {
    setState(() {
      _selectedPeriodFilter = period;
      _selectedSlot = null;

      // Adjust duration if current duration does not fit new period
      if (period != null &&
          !CollegeConfig.durationFitsPeriod(period, _selectedDuration.minutes)) {
        final valids = CollegeConfig.getValidDurations(period);
        if (valids.isNotEmpty) {
          _selectedDuration = valids.first;
        }
      }
    });
  }

  void _selectSlot(TimeSlot slot) {
    if (slot.isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot is already reserved by another student.'),
          backgroundColor: Color(0xFFEF4444),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedSlot = slot;
      // Auto-adapt duration if needed
      final slotMinutes = slot.durationMinutes;
      final matchingDuration = CollegeConfig.durationOptions.firstWhere(
        (opt) => opt.minutes == slotMinutes,
        orElse: () => _selectedDuration,
      );
      if (CollegeConfig.durationFitsPeriod(slot.period, matchingDuration.minutes)) {
        _selectedDuration = matchingDuration;
      }
    });
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );

    if (picked != null) {
      _onDateSelected(picked);
    }
  }

  void _proceedToBookingForm() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available time slot first.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    // Rule Check: Check if student already booked a slot on this date
    if (appState.studentAlreadyBookedOnDate(_selectedDate)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Single Booking Limit'),
            ],
          ),
          content: const Text(
            'Campus policy permits only 1 celebration reservation per student per day to allow fair hall access to all classmates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understand'),
            ),
          ],
        ),
      );
      return;
    }

    // Ensure slot duration fits within period
    if (!CollegeConfig.durationFitsPeriod(
        _selectedSlot!.period, _selectedDuration.minutes)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Duration of ${_selectedDuration.label} exceeds the ${_selectedSlot!.period.title} maximum time (${_selectedSlot!.period.maxMinutes} mins).',
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Calculate actual end time based on selected duration
    final startMin = _selectedSlot!.startTime.hour * 60 + _selectedSlot!.startTime.minute;
    final calculatedEndMin = startMin + _selectedDuration.minutes;
    final calculatedEndTime = TimeOfDay(
      hour: calculatedEndMin ~/ 60,
      minute: calculatedEndMin % 60,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingFormScreen(
          date: _selectedDate,
          startTime: _selectedSlot!.startTime,
          endTime: calculatedEndTime,
          duration: _selectedDuration,
          period: _selectedSlot!.period,
        ),
      ),
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

    final isHoliday = CollegeConfig.isCollegeHoliday(_selectedDate);
    final isHosteller = student.studentType == StudentType.hosteller;
    final holidayFullAccess = isHoliday && isHosteller;

    // Get slots for date
    final allSlots = appState.getSlotsForDate(_selectedDate);
    final filteredSlots = _selectedPeriodFilter == null
        ? allSlots
        : allSlots.where((s) => s.period == _selectedPeriodFilter).toList();

    // Valid duration options for current context
    final validDurations = _selectedSlot != null
        ? CollegeConfig.getValidDurations(_selectedSlot!.period)
        : (_selectedPeriodFilter != null
            ? CollegeConfig.getValidDurations(_selectedPeriodFilter!)
            : CollegeConfig.durationOptions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Celebration Slot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Choose Date',
            onPressed: _pickCustomDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Assigned Room Banner (Strict Gender Assignment)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  student.assignedRoomName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    student.genderDisplay,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              student.assignedRoomLocation,
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
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Date Picker Strip (Next 14 days)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickCustomDate,
                      icon: const Icon(Icons.date_range_rounded, size: 16),
                      label: Text(AppDateUtils.formatDateShort(_selectedDate)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Horizontal Date Selector
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final now = DateTime.now();
                      final date = DateTime(now.year, now.month, now.day)
                          .add(Duration(days: index));
                      final isSelected =
                          AppDateUtils.isSameDay(date, _selectedDate);
                      final isHolidayDate = CollegeConfig.isCollegeHoliday(date);

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => _onDateSelected(date),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : (isHolidayDate
                                        ? const Color(0xFFEC4899).withAlpha(150)
                                        : (isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0))),
                                width: isHolidayDate ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withAlpha(50),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppDateUtils.formatDayOfWeek(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white70
                                        : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppDateUtils.formatDayNumber(date),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A)),
                                  ),
                                ),
                                if (isHolidayDate)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFEC4899),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Holiday / Hosteller notice banner if holiday
                if (isHoliday)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withAlpha(isDark ? 40 : 15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEC4899).withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.celebration_rounded,
                          color: Color(0xFFEC4899),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            holidayFullAccess
                                ? '🎉 ${CollegeConfig.getHolidayName(_selectedDate)}: Full-Day booking unlocked for Hostellers!'
                                : '📌 ${CollegeConfig.getHolidayName(_selectedDate)}: College holiday rules active.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFF472B6)
                                  : const Color(0xFFBE185D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Period Filter Chips
                Text(
                  'Filter by Allowed Break',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Allowed Breaks'),
                        selected: _selectedPeriodFilter == null,
                        onSelected: (val) => _onPeriodFilterChanged(null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Morning (10:40 - 11:00)'),
                        selected:
                            _selectedPeriodFilter == SlotPeriod.morningBreak,
                        onSelected: (val) => _onPeriodFilterChanged(
                            val ? SlotPeriod.morningBreak : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Lunch (12:40 - 1:40)'),
                        selected: _selectedPeriodFilter == SlotPeriod.lunchBreak,
                        onSelected: (val) => _onPeriodFilterChanged(
                            val ? SlotPeriod.lunchBreak : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Evening (5:00 - 10:00)'),
                        selected: _selectedPeriodFilter == SlotPeriod.evening,
                        onSelected: (val) => _onPeriodFilterChanged(
                            val ? SlotPeriod.evening : null),
                      ),
                      if (holidayFullAccess) ...[
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Holiday Specials'),
                          selected: _selectedPeriodFilter ==
                              SlotPeriod.holidayFullDay,
                          onSelected: (val) => _onPeriodFilterChanged(
                              val ? SlotPeriod.holidayFullDay : null),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Duration Selector Section
                Text(
                  'Choose Celebration Duration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pricing dynamically calculated. Must fit selected break window.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                DurationSelector(
                  options: validDurations,
                  selected: _selectedDuration,
                  onSelected: (opt) {
                    setState(() => _selectedDuration = opt);
                  },
                ),
                const SizedBox(height: 20),

                // Available / Booked Time Slots Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time Slots for ${AppDateUtils.formatRelativeDate(_selectedDate)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _statusDot(const Color(0xFF10B981), 'Available'),
                        const SizedBox(width: 10),
                        _statusDot(const Color(0xFF94A3B8), 'Booked'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (filteredSlots.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: const Text('No slots found for this filter.'),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.1,
                    ),
                    itemCount: filteredSlots.length,
                    itemBuilder: (context, index) {
                      final slot = filteredSlots[index];
                      final isSelected = _selectedSlot?.id == slot.id;
                      final isBooked = slot.isBooked;

                      return InkWell(
                        onTap: isBooked ? null : () => _selectSlot(slot),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? (isDark
                                    ? const Color(0xFF1E293B).withAlpha(100)
                                    : const Color(0xFFF1F5F9))
                                : isSelected
                                    ? theme.colorScheme.primary
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isBooked
                                  ? (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0))
                                  : isSelected
                                      ? theme.colorScheme.primary
                                      : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFCBD5E1)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isBooked
                                        ? Icons.lock_outline_rounded
                                        : (isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.access_time_rounded),
                                    size: 14,
                                    color: isBooked
                                        ? const Color(0xFF94A3B8)
                                        : isSelected
                                            ? Colors.white
                                            : theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      slot.format(context),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isBooked
                                            ? const Color(0xFF94A3B8)
                                            : isSelected
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F172A)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    slot.period.title,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isBooked
                                          ? const Color(0xFF94A3B8)
                                          : isSelected
                                              ? Colors.white70
                                              : (isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B)),
                                    ),
                                  ),
                                  if (isBooked)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'BOOKED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Bar with summary and Continue button
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Booking Fee',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '₹${_selectedDuration.price}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${_selectedDuration.label})',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _selectedSlot == null
                        ? null
                        : _proceedToBookingForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 50),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Continue'),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
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

  Widget _statusDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
