import 'package:flutter/material.dart';
import '../services/compatibility_catalog.dart';

class CompatibilityScreen extends StatelessWidget {
  const CompatibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compatibilité caméras')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cameraFamilies.length,
        itemBuilder: (context, index) {
          final family = cameraFamilies[index];
          final status = family.openProtocolPreferred ? 'Compatible' : 'Partiel';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: Icon(family.openProtocolPreferred ? Icons.verified : Icons.extension),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(family.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                              Chip(label: Text(status)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(family.notes, style: const TextStyle(color: Color(0xFF91A4BB))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
