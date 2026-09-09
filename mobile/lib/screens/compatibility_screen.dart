import 'package:flutter/material.dart';
import '../services/compatibility_catalog.dart';

class CompatibilityScreen extends StatelessWidget {
  const CompatibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compatibilité caméras')),
      body: ListView.separated(
        itemCount: cameraFamilies.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final family = cameraFamilies[index];
          return ListTile(
            leading: Icon(family.openProtocolPreferred ? Icons.verified : Icons.extension),
            title: Text(family.name),
            subtitle: Text(family.notes),
          );
        },
      ),
    );
  }
}
