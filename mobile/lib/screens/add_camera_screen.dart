import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../services/compatibility_catalog.dart';
import '../services/network_discovery_service.dart';

class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({super.key});

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  final _discovery = NetworkDiscoveryService();
  String _family = cameraFamilies.first.name;
  bool _scanning = false;

  Future<void> _scanNetwork() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    final results = await _discovery.scanLocalSubnet();
    if (!mounted) return;
    setState(() => _scanning = false);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1D30),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Caméras détectées', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  results.isEmpty
                      ? 'Aucune caméra compatible trouvée sur le réseau local. Vérifie que le téléphone et la caméra sont sur le même Wi-Fi, puis réessaie. Tu peux aussi utiliser Ajout manuel.'
                      : '${results.length} appareil(s) trouvé(s). Un flux n’est prérempli que lorsqu’il a été confirmé par le test RTSP.',
                  style: const TextStyle(color: Color(0xFF91A4BB)),
                ),
                const SizedBox(height: 14),
                if (results.isNotEmpty)
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final camera = results[index];
                        final status = camera.hasValidatedStream
                            ? 'Flux RTSP validé'
                            : camera.hasRtspServer
                                ? 'Serveur RTSP détecté — flux non confirmé'
                                : 'Services caméra détectés — RTSP non détecté';
                        return ListTile(
                          tileColor: const Color(0xFF0B1929),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: Icon(
                            camera.hasValidatedStream ? Icons.verified : Icons.videocam_outlined,
                            color: camera.hasValidatedStream ? const Color(0xFF4FD6FF) : const Color(0xFF91A4BB),
                          ),
                          title: Text(camera.host),
                          subtitle: Text('Ports: ${camera.openPorts.join(', ')} • $status'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(this.context).push(MaterialPageRoute(
                              builder: (_) => _ManualCameraForm(
                                family: _family,
                                initialHost: camera.host,
                                initialUrl: camera.bestStream,
                                streamValidated: camera.hasValidatedStream,
                              ),
                            ));
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openManualForm() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ManualCameraForm(family: _family)));
  }

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF91A4BB);
    const panel = Color(0xFF0F1D30);
    const line = Color(0xFF203751);

    final methods = <_MethodData>[
      const _MethodData(Icons.qr_code_2, 'QR code', 'Présente le QR devant la caméra.'),
      const _MethodData(Icons.graphic_eq, 'Son / bip-bip', 'Envoie les données Wi-Fi par signal acoustique.'),
      const _MethodData(Icons.bluetooth, 'Bluetooth', 'Appairage Bluetooth si disponible.'),
      const _MethodData(Icons.wifi_tethering, 'Wi-Fi AP', 'Connexion directe au hotspot de la caméra.'),
      const _MethodData(Icons.radar, 'ONVIF / RTSP', 'Détection automatique sur le réseau.'),
      const _MethodData(Icons.edit, 'Ajout manuel', 'URL RTSP/HTTP/MJPEG/P2P en secours.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une caméra')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: panel,
              border: Border.all(color: line),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choisis une méthode', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('L’application privilégie la détection automatique. Le mode manuel reste disponible en secours.', style: TextStyle(color: muted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _scanning ? null : _scanNetwork,
            icon: _scanning
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.radar),
            label: Text(_scanning ? 'Recherche en cours…' : 'Scanner les caméras'),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: method.title == 'Ajout manuel'
                    ? _openManualForm
                    : method.title == 'ONVIF / RTSP'
                        ? _scanNetwork
                        : () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(method.title),
                                content: Text(
                                  method.title == 'Son / bip-bip'
                                      ? 'Cette méthode nécessite le protocole audio ou le SDK du fabricant pour fonctionner réellement.'
                                      : method.description,
                                ),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                              ),
                            ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1929),
                    border: Border.all(color: line),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(method.icon, size: 34, color: const Color(0xFF4FD6FF)),
                      const Spacer(),
                      Text(method.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(method.description, style: const TextStyle(color: muted, height: 1.25)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _family,
            decoration: const InputDecoration(labelText: 'Famille / application d’origine'),
            items: cameraFamilies.map((family) => DropdownMenuItem(value: family.name, child: Text(family.name))).toList(),
            onChanged: (value) => setState(() => _family = value ?? _family),
          ),
        ],
      ),
    );
  }
}

class _ManualCameraForm extends StatefulWidget {
  const _ManualCameraForm({
    required this.family,
    this.initialHost = '',
    this.initialUrl = '',
    this.streamValidated = false,
  });

  final String family;
  final String initialHost;
  final String initialUrl;
  final bool streamValidated;

  @override
  State<_ManualCameraForm> createState() => _ManualCameraFormState();
}

class _ManualCameraFormState extends State<_ManualCameraForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _url;
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _location = TextEditingController();
  CameraConnectionType _type = CameraConnectionType.rtsp;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialHost.isEmpty ? '' : 'Caméra ${widget.initialHost}');
    _url = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _username.dispose();
    _password.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialHost.isEmpty ? 'Ajout manuel' : 'Caméra détectée')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.initialHost.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1D30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF203751)),
                ),
                child: Text(
                  widget.streamValidated
                      ? 'Flux RTSP validé automatiquement sur ${widget.initialHost}'
                      : 'Caméra détectée sur ${widget.initialHost}, mais aucun flux RTSP n’a encore été confirmé. Entre l’URL ou les identifiants si nécessaire.',
                  style: TextStyle(color: widget.streamValidated ? const Color(0xFF4FD6FF) : const Color(0xFF91A4BB)),
                ),
              ),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nom de la caméra'), validator: (v) => v == null || v.trim().isEmpty ? 'Nom obligatoire' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<CameraConnectionType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type de connexion'),
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
              decoration: const InputDecoration(labelText: 'Adresse du flux', hintText: 'rtsp://192.168.1.50:554/stream1'),
              validator: (value) {
                if (_type == CameraConnectionType.proprietary) return null;
                final uri = Uri.tryParse(value?.trim() ?? '');
                if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) return 'Adresse RTSP/HTTP valide obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _username, decoration: const InputDecoration(labelText: 'Utilisateur caméra')),
            const SizedBox(height: 12),
            TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe caméra')),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Lieu (facultatif)')),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.of(context).pop(CameraDevice(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: _name.text.trim(),
                  family: widget.family,
                  streamUrl: _url.text.trim(),
                  connectionType: _type,
                  username: _username.text.trim(),
                  password: _password.text,
                  location: _location.text.trim(),
                ));
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

class _MethodData {
  const _MethodData(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}
