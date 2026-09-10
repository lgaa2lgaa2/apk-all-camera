import 'package:flutter/material.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final List<_SessionItem> _sessions = <_SessionItem>[
    const _SessionItem('Samsung Galaxy', 'Android · session actuelle', true),
    const _SessionItem('iPhone', 'iOS · dernière connexion hier', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.devices),
              title: Text(session.name),
              subtitle: Text(session.detail),
              trailing: session.current
                  ? const Chip(label: Text('Actuelle'))
                  : TextButton(
                      onPressed: () => setState(() => _sessions.removeAt(index)),
                      child: const Text('Déconnecter'),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _SessionItem {
  const _SessionItem(this.name, this.detail, this.current);
  final String name;
  final String detail;
  final bool current;
}
