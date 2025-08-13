import 'package:flutter/material.dart';

class CareCheckoutScreen extends StatefulWidget {
  const CareCheckoutScreen({super.key});

  @override
  State<CareCheckoutScreen> createState() => _CareCheckoutScreenState();
}

class _CareCheckoutScreenState extends State<CareCheckoutScreen> {
  String method = 'Card';
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> provider = Map<String, dynamic>.from(args['provider'] ?? {});
    final String slot = (args['slot'] ?? '') as String;
    final int amount = (args['amount'] ?? 50) as int;

    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Header
                    Container(
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Text(
                            'Checkout',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Booking Summary', style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text(provider['name'] ?? 'Specialist'),
                                  const SizedBox(height: 4),
                                  Text('${provider['specialty'] ?? ''} • ${provider['city'] ?? ''}, ${provider['country'] ?? ''}'),
                                  const SizedBox(height: 4),
                                  Text('Slot: $slot'),
                                  const SizedBox(height: 8),
                                  Text('Amount: £$amount', style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _methodChip('Card'),
                                _methodChip('UPI'),
                                _methodChip('Netbanking'),
                                _methodChip('Wallet'),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        setState(() => isProcessing = true);
                                        await Future.delayed(const Duration(seconds: 1));
                                        if (!mounted) return;
                                        setState(() => isProcessing = false);
                                        // Show success and go to home
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Payment Successful'),
                                            content: const Text('Your session is booked. Meeting invite will be sent to your email.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF667eea),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isProcessing ? 'Processing...' : 'Pay Now',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodChip(String value) {
    final bool selected = method == value;
    return InkWell(
      onTap: () => setState(() => method = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF667eea) : Colors.grey[100],
          border: Border.all(color: selected ? const Color(0xFF667eea) : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(value, style: TextStyle(color: selected ? Colors.white : Colors.grey[800])),
      ),
    );
  }
}
