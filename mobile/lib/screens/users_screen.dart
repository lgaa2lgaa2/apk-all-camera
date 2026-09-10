import 'package:flutter/material.dart';
import '../models/access_control.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<AppUser> _users = <AppUser>[
    const AppUser(id: 'admin', name: 'Administrateur', role: UserRole.admin, cameraIds: <String>[]),
    const AppUser(id: 'user-1', name: 'Utilisateur 1', role: UserRole.user, cameraIds: <String>['cam1']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Inviter'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(user.role == UserRole.admin ? Icons.admin_panel_settings : Icons.person)),
              title: Text(user.name),
              subtitle: Text(user.role == UserRole.admin ? 'Administrateur' : '${user.cameraIds.length} caméra(s) autorisée(s)'),
              trailing: user.role == UserRole.admin ? const Chip(label: Text('Admin')) : const Icon(Icons.chevron_right),
              onTap: user.role == UserRole.admin ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PermissionsScreen(user: user))),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addUser() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inviter un utilisateur'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nom ou e-mail')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Ajouter')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    setState(() => _users.add(AppUser(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name, role: UserRole.user, cameraIds: const <String>[])));
  }
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late bool live = widget.user.permissions.liveView;
  late bool ptz = widget.user.permissions.ptz;
  late bool audio = widget.user.permissions.audio;
  late bool recordings = widget.user.permissions.recordings;
  late bool alerts = widget.user.permissions.alerts;
  late bool storage = widget.user.permissions.manageStorage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Droits · ${widget.user.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Caméras autorisées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Card(child: CheckboxListTile(value: true, onChanged: null, title: Text('Caméra principale'))),
          const SizedBox(height: 16),
          const Text('Droits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SwitchListTile(value: live, onChanged: (v) => setState(() => live = v), title: const Text('Vue en direct')),
          SwitchListTile(value: audio, onChanged: (v) => setState(() => audio = v), title: const Text('Audio')),
          SwitchListTile(value: ptz, onChanged: (v) => setState(() => ptz = v), title: const Text('PTZ')),
          SwitchListTile(value: recordings, onChanged: (v) => setState(() => recordings = v), title: const Text('Enregistrements')),
          SwitchListTile(value: alerts, onChanged: (v) => setState(() => alerts = v), title: const Text('Alertes')),
          SwitchListTile(value: storage, onChanged: (v) => setState(() => storage = v), title: const Text('Gestion stockage')),
        ],
      ),
    );
  }
}
