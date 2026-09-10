import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AdminTile(icon: Icons.people_alt_outlined, title: 'Utilisateurs', subtitle: 'Créer, modifier, suspendre et gérer les accès.'),
          _AdminTile(icon: Icons.videocam_outlined, title: 'Caméras', subtitle: 'Attribution des caméras et droits par utilisateur.'),
          _AdminTile(icon: Icons.history, title: 'Journal d’audit', subtitle: 'Historique des connexions et actions sensibles.'),
          _AdminTile(icon: Icons.security, title: 'Sécurité', subtitle: 'Sessions, mots de passe, limites et permissions.'),
          _AdminTile(icon: Icons.dns_outlined, title: 'Backend', subtitle: 'État API, base de données, notifications et relais éventuel.'),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4FD6FF)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
