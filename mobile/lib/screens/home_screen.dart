import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../services/camera_registry.dart';
import 'add_camera_screen.dart';
import 'admin_screen.dart';
import 'alerts_screen.dart';
import 'compatibility_screen.dart';
import 'distribution_screen.dart';
import 'mosaic_screen.dart';
import 'permissions_screen.dart';
import 'player_screen.dart';
import 'sessions_screen.dart';
import 'settings_screen.dart';
import 'storage_screen.dart';
import 'system_status_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _registry = CameraRegistry();
  List<CameraDevice> _cameras = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final cameras = await _registry.load();
    if (!mounted) return;
    setState(() {
      _cameras = cameras;
      _loading = false;
    });
  }

  Future<void> _addCamera() async {
    final camera = await Navigator.of(context).push<CameraDevice>(
      MaterialPageRoute(builder: (_) => const AddCameraScreen()),
    );
    if (camera == null) return;
    final updated = [..._cameras, camera];
    await _registry.save(updated);
    if (mounted) setState(() => _cameras = updated);
  }

  Future<void> _remove(CameraDevice camera) async {
    final updated = _cameras.where((item) => item.id != camera.id).toList();
    await _registry.save(updated);
    if (mounted) setState(() => _cameras = updated);
  }

  void _open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APK All Camera'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.grid_view_rounded),
            onSelected: (value) {
              switch (value) {
                case 'mosaic': _open(MosaicScreen(cameras: _cameras)); break;
                case 'alerts': _open(const AlertsScreen()); break;
                case 'storage': _open(const StorageScreen()); break;
                case 'users': _open(const UsersScreen()); break;
                case 'permissions': _open(const PermissionsScreen()); break;
                case 'sessions': _open(const SessionsScreen()); break;
                case 'compat': _open(const CompatibilityScreen()); break;
                case 'settings': _open(const SettingsScreen()); break;
                case 'admin': _open(const AdminScreen()); break;
                case 'system': _open(const SystemStatusScreen()); break;
                case 'distribution': _open(const DistributionScreen()); break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'mosaic', child: Text('Mosaïque 2×2')),
              PopupMenuItem(value: 'alerts', child: Text('Alertes')),
              PopupMenuItem(value: 'storage', child: Text('Stockage')),
              PopupMenuItem(value: 'users', child: Text('Utilisateurs')),
              PopupMenuItem(value: 'permissions', child: Text('Permissions')),
              PopupMenuItem(value: 'sessions', child: Text('Sessions')),
              PopupMenuItem(value: 'compat', child: Text('Compatibilité')),
              PopupMenuItem(value: 'settings', child: Text('Réglages')),
              PopupMenuItem(value: 'admin', child: Text('Panel Admin')),
              PopupMenuItem(value: 'system', child: Text('État système')),
              PopupMenuItem(value: 'distribution', child: Text('Distribution')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCamera,
        icon: const Icon(Icons.add),
        label: const Text('Caméra'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  _DashboardHeader(cameraCount: _cameras.length),
                  const SizedBox(height: 16),
                  if (_cameras.isEmpty)
                    const _EmptyState()
                  else
                    ..._cameras.map((camera) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: const CircleAvatar(child: Icon(Icons.videocam)),
                          title: Text(camera.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${camera.family}${camera.location.isEmpty ? '' : ' • ${camera.location}'}'),
                          onTap: () => _open(PlayerScreen(camera: camera)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') _remove(camera);
                            },
                            itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Supprimer'))],
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.cameraCount});
  final int cameraCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tableau de bord', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Surveillance et gestion centralisées', style: TextStyle(color: Color(0xFF91A4BB))),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: [
            _StatCard(label: 'Caméras', value: '$cameraCount', icon: Icons.videocam),
            const _StatCard(label: 'Alertes', value: '—', icon: Icons.notifications),
            const _StatCard(label: 'Stockage', value: '—', icon: Icons.storage),
            const _StatCard(label: 'Utilisateurs', value: '—', icon: Icons.people),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: Color(0xFF91A4BB))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.videocam_outlined, size: 72, color: Color(0xFF4FD6FF)),
            const SizedBox(height: 16),
            Text('Aucune caméra', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Ajoute une caméra avec le scan automatique ONVIF/RTSP, ou utilise le mode manuel en secours.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
