import 'package:flutter/material.dart';

class SecurityDetailsPage extends StatelessWidget {
  const SecurityDetailsPage({
    super.key,
    required this.incidents,
  });

  final List<Map<String, dynamic>> incidents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050816),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Security Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: incidents.isEmpty
          ? const Center(
              child: Text(
                "No security incidents",
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {

                final incident = incidents[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        incident['incident_type']
                            .toString(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Reason: ${incident['reason']}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Device: ${incident['device_info']}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "IP: ${incident['ip_address']}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Date: ${incident['created_at']}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
    );
  }
}