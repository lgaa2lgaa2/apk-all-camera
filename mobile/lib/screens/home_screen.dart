import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../services/camera_registry.dart';
import 'add_camera_screen.dart';
import 'compatibility_screen.dart';
import 'player_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APK All Camera'),
        actions: [
          IconButton(
            tooltip: 'Compatibilité',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CompatibilityScreen())),
            icon: const Icon(Icons.extension),
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
          : _cameras.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  itemCount: _cameras.length,
                  itemBuilder: (context, index) {
                    final camera = _cameras[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.videocam)),
                        title: Text(camera.name),
                        subtitle: Text('${camera.family}${camera.location.isEmpty ? '' : ' • ${camera.location}'}'),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(camera: camera))),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') _remove(camera);
                          },
                          itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Supprimer'))],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_outlined, size: 72),
            const SizedBox(height: 16),
            Text('Aucune caméra', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Ajoute une caméra RTSP/HTTP ou sélectionne sa famille pour préparer son connecteur.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
