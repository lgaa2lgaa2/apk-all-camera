import 'package:flutter/material.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF91A4BB);
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Caméras autorisées', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Choisis précisément les caméras accessibles à chaque utilisateur.', style: TextStyle(color: muted)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Droits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Live')),
                      Chip(label: Text('Enregistrements')),
                      Chip(label: Text('Écouter')),
                      Chip(label: Text('Parler')),
                      Chip(label: Text('PTZ / zoom')),
                      Chip(label: Text('Notifications')),
                      Chip(label: Text('Capture')),
                      Chip(label: Text('Stockage')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: true,
            onChanged: null,
            title: const Text('Accès temporaire'),
            subtitle: const Text('Dates de début et de fin gérées par le compte administrateur.'),
          ),
        ],
      ),
    );
  }
}
