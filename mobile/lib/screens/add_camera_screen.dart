import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../models/setup_method.dart';
import '../services/compatibility_catalog.dart';

class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({super.key});

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _url = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _location = TextEditingController();
  String _family = cameraFamilies.first.name;
  CameraConnectionType _type = CameraConnectionType.rtsp;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _username.dispose();
    _password.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _showSetupMethods() async {
    final method = await showModalBottomSheet<CameraSetupMethod>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: CameraSetupMethod.values.map((method) {
            final icon = switch (method) {
              CameraSetupMethod.qr => Icons.qr_code_2,
              CameraSetupMethod.acoustic => Icons.graphic_eq,
              CameraSetupMethod.bluetooth => Icons.bluetooth,
              CameraSetupMethod.accessPoint => Icons.wifi_tethering,
              CameraSetupMethod.networkDiscovery => Icons.radar,
              CameraSetupMethod.manual => Icons.edit,
            };
            return ListTile(
              leading: Icon(icon),
              title: Text(method.label),
              subtitle: Text(method.description),
              onTap: () => Navigator.of(context).pop(method),
            );
          }).toList(),
        ),
      ),
    );

    if (!mounted || method == null || method == CameraSetupMethod.manual) return;

    final isAcoustic = method == CameraSetupMethod.acoustic;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(method.label),
        content: Text(
          isAcoustic
              ? 'Le mode son / bip-bip est maintenant prévu dans APK All Camera. Pour réellement configurer une caméra par son, il faut connaître le protocole audio ou disposer du SDK du fabricant.'
              : '${method.description}\n\nLe connecteur spécifique sera utilisé lorsqu’il est disponible pour la famille sélectionnée.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une caméra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Méthode d’installation'),
                subtitle: const Text('QR code, son bip-bip, Bluetooth, Wi-Fi AP, détection réseau ou manuel'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showSetupMethods,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom de la caméra', border: OutlineInputBorder()),
              validator: (value) => value == null || value.trim().isEmpty ? 'Nom obligatoire' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _family,
              decoration: const InputDecoration(labelText: 'Famille / application d’origine', border: OutlineInputBorder()),
              items: cameraFamilies.map((family) => DropdownMenuItem(value: family.name, child: Text(family.name))).toList(),
              onChanged: (value) => setState(() => _family = value ?? _family),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CameraConnectionType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type de connexion', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: CameraConnectionType.rtsp, child: Text('RTSP')),
                DropdownMenuItem(value: CameraConnectionType.http, child: Text('HTTP vidéo')),
                DropdownMenuItem(value: CameraConnectionType.mjpeg, child: Text('MJPEG')),
                DropdownMenuItem(value: CameraConnectionType.proprietary, child: Text('Protocole propriétaire / P2P')),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Adresse du flux',
                hintText: 'rtsp://192.168.1.50:554/stream1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_type == CameraConnectionType.proprietary) return null;
                final uri = Uri.tryParse(value?.trim() ?? '');
                if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) return 'Adresse RTSP/HTTP valide obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _username, decoration: const InputDecoration(labelText: 'Utilisateur caméra', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe caméra', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Lieu (facultatif)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final camera = CameraDevice(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: _name.text.trim(),
                  family: _family,
                  streamUrl: _url.text.trim(),
                  connectionType: _type,
                  username: _username.text.trim(),
                  password: _password.text,
                  location: _location.text.trim(),
                );
                Navigator.of(context).pop(camera);
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Ajouter la caméra'),
            ),
          ],
        ),
      ),
    );
  }
}
