import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/app_state.dart';
import 'main_navigation_shell.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'UPI';
  bool _paid = false;

  void _pay() {
    context.read<AppState>().markBookingPaid(widget.booking.id);
    setState(() => _paid = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('₹${widget.booking.price} paid successfully using $_method.\n\nThis is a demo payment; no real money is charged.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 2)),
                (route) => false,
              );
            },
            child: const Text('View My Bookings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, size: 44),
                const SizedBox(height: 12),
                const Text('Celebration Hall Fee', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Booking ${booking.id}', style: TextStyle(color: theme.colorScheme.primary)),
                const SizedBox(height: 18),
                Text('₹${booking.price}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Pay after mentor approval', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Choose Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          RadioListTile<String>(value: 'UPI', groupValue: _method, onChanged: _paid ? null : (v) => setState(() => _method = v!), title: const Text('UPI'), secondary: const Icon(Icons.qr_code_2_rounded)),
          RadioListTile<String>(value: 'Card', groupValue: _method, onChanged: _paid ? null : (v) => setState(() => _method = v!), title: const Text('Debit / Credit Card'), secondary: const Icon(Icons.credit_card_rounded)),
          RadioListTile<String>(value: 'Cash at Hall Desk', groupValue: _method, onChanged: _paid ? null : (v) => setState(() => _method = v!), title: const Text('Cash at Hall Desk'), secondary: const Icon(Icons.payments_outlined)),
          const SizedBox(height: 18),
          if (!_paid)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _pay,
                icon: const Icon(Icons.lock_outline_rounded),
                label: Text('Pay ₹${booking.price}'),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Approval Status'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Prototype note: payment is simulated locally. Connect a real payment gateway only when backend/payment integration is added.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}
