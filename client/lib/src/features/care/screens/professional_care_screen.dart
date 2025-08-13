import 'package:flutter/material.dart';

class ProfessionalCareScreen extends StatefulWidget {
  const ProfessionalCareScreen({super.key});

  @override
  State<ProfessionalCareScreen> createState() => _ProfessionalCareScreenState();
}

class _ProfessionalCareScreenState extends State<ProfessionalCareScreen> {
  String specialty = 'Psychiatrist';
  final TextEditingController locationController = TextEditingController();

  final List<Map<String, dynamic>> providers = [
    {
      'name': 'Dr. Aisha Verma',
      'specialty': 'Psychiatrist',
      'city': 'Mumbai',
      'country': 'India',
      'rating': 4.8,
      'phone': '+91 22 5555 1234',
      'email': 'aisha.verma@careclinic.in',
      'availability': ['Tomorrow 10:00', 'Tomorrow 14:30', 'Fri 11:00', 'Mon 09:30'],
      'fee': 40,
    },
    {
      'name': 'Dr. Daniel Brooks',
      'specialty': 'Psychologist',
      'city': 'New York',
      'country': 'United States',
      'rating': 4.6,
      'phone': '+1 212-555-0198',
      'email': 'dbrooks@mindwell.us',
      'availability': ['Today 16:00', 'Thu 10:00', 'Fri 13:00'],
      'fee': 75,
    },
    {
      'name': 'Dr. Emily Zhang',
      'specialty': 'Psychiatrist',
      'city': 'Toronto',
      'country': 'Canada',
      'rating': 4.7,
      'phone': '+1 416-555-0147',
      'email': 'emily.zhang@calmminds.ca',
      'availability': ['Tomorrow 09:00', 'Mon 15:30'],
      'fee': 60,
    },
    {
      'name': 'Dr. Oliver Smith',
      'specialty': 'Psychologist',
      'city': 'London',
      'country': 'United Kingdom',
      'rating': 4.5,
      'phone': '+44 20 7946 1234',
      'email': 'oliver.smith@balance.uk',
      'availability': ['Thu 09:30', 'Thu 17:00', 'Sat 10:00'],
      'fee': 70,
    },
    {
      'name': 'Dr. Mia Nguyen',
      'specialty': 'Psychologist',
      'city': 'Sydney',
      'country': 'Australia',
      'rating': 4.9,
      'phone': '+61 2 5550 7777',
      'email': 'mia.nguyen@mindful.au',
      'availability': ['Fri 09:00', 'Fri 12:30', 'Mon 10:30'],
      'fee': 80,
    },
  ];

  final Map<String, String> helplinesByCountry = const {
    'india': 'Kiran Helpline: 1800-599-0019',
    'united states': '988 Suicide & Crisis Lifeline: 988',
    'usa': '988 Suicide & Crisis Lifeline: 988',
    'canada': 'Talk Suicide Canada: 1-833-456-4566',
    'united kingdom': 'Samaritans: 116 123',
    'uk': 'Samaritans: 116 123',
    'australia': 'Lifeline: 13 11 14',
  };

  String _inferCountryFromInput(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('india') || lower.contains('mumbai') || lower.contains('delhi')) return 'india';
    if (lower.contains('canada') || lower.contains('toronto') || lower.contains('vancouver')) return 'canada';
    if (lower.contains('united kingdom') || lower.contains('london') || lower.contains('manchester') || lower.contains('uk')) return 'united kingdom';
    if (lower.contains('australia') || lower.contains('sydney') || lower.contains('melbourne')) return 'australia';
    if (lower.contains('united states') || lower.contains('usa') || lower.contains('new york') || lower.contains('los angeles')) return 'united states';
    return '';
  }

  List<Map<String, dynamic>> _filteredProviders() {
    final query = locationController.text.trim().toLowerCase();
    return providers.where((p) {
      final matchesSpecialty = p['specialty'] == specialty;
      if (query.isEmpty) return matchesSpecialty;
      final inCity = (p['city'] as String).toLowerCase().contains(query);
      final inCountry = (p['country'] as String).toLowerCase().contains(query);
      return matchesSpecialty && (inCity || inCountry);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProviders();
    final inferred = _inferCountryFromInput(locationController.text);
    final helplineText = helplinesByCountry[inferred];

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
                            'Professional Care',
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
                            const SizedBox(height: 8),
                            const Text(
                              'Find the right specialist near you',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: locationController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter city or country',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: specialty,
                                  underline: const SizedBox.shrink(),
                                  items: const [
                                    DropdownMenuItem(value: 'Psychiatrist', child: Text('Psychiatrist')),
                                    DropdownMenuItem(value: 'Psychologist', child: Text('Psychologist')),
                                  ],
                                  onChanged: (v) => setState(() => specialty = v ?? 'Psychiatrist'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (helplineText != null && helplineText.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withValues(alpha: 0.08),
                                  border: Border.all(color: const Color(0xFF667eea)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.support_agent, color: Color(0xFF667eea)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Helpline in your area',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            helplineText,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final p = filtered[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(0xFF667eea).withValues(alpha: 0.1),
                                          child: const Icon(Icons.person, color: Color(0xFF667eea)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${p['specialty']} • ${p['city']}, ${p['country']}',
                                                style: TextStyle(color: Colors.grey[700]),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                                  const SizedBox(width: 4),
                                                  Text('${p['rating']}'),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () {},
                                                    icon: const Icon(Icons.call, size: 16),
                                                    label: const Text('Call'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/care/provider',
                                                        arguments: p,
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF667eea),
                                                    ),
                                                    child: const Text('View'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
