import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/app_state.dart';
import '../utils/date_utils.dart';
import 'mentor_review_screen.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loggedIn = false;
  String _mentorName = '';
  String _mentorPhone = '';

  @override
  void dispose() { _nameController.dispose(); _phoneController.dispose(); super.dispose(); }

  void _login() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final appState = context.read<AppState>();
    final requests = appState.getMentorBookings(mentorName: name, mentorPhone: phone);
    if (name.isEmpty || phone.isEmpty || requests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mentor account not found. Use the exact mentor name and phone assigned to the student.')));
      return;
    }
    setState(() { _loggedIn = true; _mentorName = name; _mentorPhone = phone; });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!_loggedIn) return _loginView(context);
    final bookings = appState.getMentorBookings(mentorName: _mentorName, mentorPhone: _mentorPhone);
    final pending = bookings.where((b) => b.status == BookingStatus.pending).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        actions: [
          IconButton(onPressed: () => setState(() => _loggedIn = false), icon: const Icon(Icons.logout_rounded), tooltip: 'Mentor Logout'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Welcome, $_mentorName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Review booking requests assigned to you.'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(15), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.pending_actions_rounded), const SizedBox(width: 12),
              Text('${pending.length} Pending Request${pending.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 18),
          if (bookings.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No booking requests assigned to you.'))),
          ...bookings.map((booking) => _bookingCard(context, booking)),
        ],
      ),
    );
  }

  Widget _loginView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.supervisor_account_rounded, size: 64),
              const SizedBox(height: 16),
              const Text('Mentor / Class Teacher Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Use the mentor name and phone number assigned to the student booking.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Mentor Name', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 14),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mentor Phone Number', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: _login, icon: const Icon(Icons.login_rounded), label: const Text('Login as Mentor')),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Back to Student Login')),
              const SizedBox(height: 20),
              const Text('Prototype: mentor accounts are matched locally against booking mentor details. No backend is connected.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(BuildContext context, Booking booking) {
    final pending = booking.status == BookingStatus.pending;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(booking.id, style: const TextStyle(fontWeight: FontWeight.bold)), Chip(label: Text(booking.status.displayName))]),
        const SizedBox(height: 8),
        Text(booking.studentName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        Text('${booking.studentRegNo} • ${booking.studentBranch}'),
        const SizedBox(height: 8),
        Text('${booking.celebrationType} • ${AppDateUtils.formatDate(booking.date)}'),
        Text('${booking.startTime.format(context)} - ${booking.endTime.format(context)} • ${booking.roomName}'),
        Text('Fee: ₹${booking.price}'),
        if (pending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: () => _openReview(context, booking), icon: const Icon(Icons.check_circle_outline), label: const Text('Review / Approve'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => _reject(context, booking), icon: const Icon(Icons.cancel_outlined), label: const Text('Reject'))),
          ]),
        ],
      ])),
    );
  }

  void _openReview(BuildContext context, Booking booking) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MentorReviewScreen(bookingId: booking.id)));
  }

  void _reject(BuildContext context, Booking booking) {
    context.read<AppState>().updateBookingStatus(booking.id, BookingStatus.rejected, comment: 'Rejected by ${booking.mentorName}. Please contact your mentor for clarification.');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking rejected.')));
  }
}
