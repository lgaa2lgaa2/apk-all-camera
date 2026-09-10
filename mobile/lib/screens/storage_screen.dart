import 'package:flutter/material.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget storageCard(String title, String subtitle, IconData icon) => Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Stockage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          storageCard('microSD', 'Stockage local de la caméra', Icons.sd_card),
          storageCard('NAS', 'Serveur personnel / partage réseau', Icons.dns),
          storageCard('Cloud', 'Stockage distant', Icons.cloud),
          storageCard('Téléphone', 'Enregistrements locaux', Icons.phone_android),
          storageCard('NVR', 'Enregistreur réseau', Icons.video_library),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Formater la carte SD ?'),
                  content: const Text('Cette action doit être autorisée par la caméra et supprimera les enregistrements présents.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande de formatage prête à être envoyée si le connecteur caméra le permet.')));
              }
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Formater microSD'),
          ),
        ],
      ),
    );
  }
}
