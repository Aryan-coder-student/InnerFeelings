import 'package:flutter/material.dart';

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({super.key});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> provider =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};

    final List<String> availability = List<String>.from(provider['availability'] ?? []);
    final int fee = (provider['fee'] as int?) ?? 50;

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
                    // Status bar + header
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
                            'Provider Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFF667eea).withValues(alpha: 0.1),
                                  child: const Icon(Icons.person, color: Color(0xFF667eea), size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider['name'] ?? 'Specialist',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${provider['specialty'] ?? ''} • ${provider['city'] ?? ''}, ${provider['country'] ?? ''}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text('${provider['rating'] ?? 4.5}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                  const Text('Contact', style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.phone, size: 16),
                                    const SizedBox(width: 8),
                                    Text(provider['phone'] ?? ''),
                                  ]),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    const Icon(Icons.email, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(provider['email'] ?? '')),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Select an available slot', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availability.map((slot) {
                                final isSelected = selectedSlot == slot;
                                return InkWell(
                                  onTap: () => setState(() => selectedSlot = slot),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF667eea) : Colors.grey[100],
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      slot,
                                      style: TextStyle(color: isSelected ? Colors.white : Colors.grey[800]),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selectedSlot == null
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                          context,
                                          '/care/checkout',
                                          arguments: {
                                            'provider': provider,
                                            'slot': selectedSlot,
                                            'amount': fee,
                                          },
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
                                  selectedSlot == null ? 'Select a slot' : 'Book & Pay • £$fee',
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
}
