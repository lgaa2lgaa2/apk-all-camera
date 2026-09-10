import 'package:flutter/material.dart';

class SystemStatusScreen extends StatelessWidget {
  const SystemStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const ok = Color(0xFF4FD6FF);
    return Scaffold(
      appBar: AppBar(title: const Text('État système')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StatusTile(title: 'HTTPS / TLS', subtitle: 'Chiffrement requis pour l’API et l’administration.', icon: Icons.lock_outline, color: ok),
          _StatusTile(title: 'API', subtitle: 'Statut à connecter au backend VPS.', icon: Icons.api_outlined, color: ok),
          _StatusTile(title: 'Base de données', subtitle: 'Statut à connecter au backend VPS.', icon: Icons.storage_outlined, color: ok),
          _StatusTile(title: 'Notifications', subtitle: 'Statut à connecter au service push.', icon: Icons.notifications_active_outlined, color: ok),
          _StatusTile(title: 'Relais vidéo', subtitle: 'Fallback uniquement quand la connexion directe est impossible.', icon: Icons.swap_horiz, color: ok),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.title, required this.subtitle, required this.icon, required this.color});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
