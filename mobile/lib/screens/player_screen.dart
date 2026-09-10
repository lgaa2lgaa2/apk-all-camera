import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/camera.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.camera,
    this.enableNativePlayer = true,
  });

  final CameraDevice camera;
  final bool enableNativePlayer;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VlcPlayerController? _controller;
  String? _error;
  bool _muted = false;
  bool _recording = false;
  bool _fullscreen = false;

  bool get _nativePlayerAvailable => !kIsWeb && widget.enableNativePlayer;

  @override
  void initState() {
    super.initState();
    if (_nativePlayerAvailable && widget.camera.streamUrl.isNotEmpty) {
      final uri = widget.camera.authenticatedUri;
      _controller = VlcPlayerController.network(
        uri.toString(),
        hwAcc: HwAcc.auto,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    }
  }

  @override
  void dispose() {
    if (_fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    final next = !_muted;
    await controller.setVolume(next ? 0 : 100);
    if (mounted) setState(() => _muted = next);
  }

  Future<void> _snapshot() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final Uint8List? snapshot = await controller.takeSnapshot();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snapshot == null || snapshot.isEmpty ? 'Capture indisponible.' : 'Photo capturée.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture indisponible.')));
    }
  }

  Future<void> _toggleRecording() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (_recording) {
        await controller.stopRecording();
        if (mounted) setState(() => _recording = false);
        return;
      }
      final bool started = await controller.startRecording('/storage/emulated/0/Download') ?? false;
      if (mounted) setState(() => _recording = started);
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enregistrement indisponible.')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enregistrement indisponible.')));
    }
  }

  Future<void> _toggleFullscreen() async {
    final next = !_fullscreen;
    if (next) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    if (mounted) setState(() => _fullscreen = next);
  }

  void _unsupported(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature indisponible pour cette caméra sans protocole ONVIF ou SDK fabricant compatible.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasConfiguredStream = widget.camera.streamUrl.isNotEmpty;
    final available = hasConfiguredStream && (controller != null || !widget.enableNativePlayer);
    return Scaffold(
      appBar: AppBar(title: Text(widget.camera.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF08111F),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF203751)),
              ),
              child: controller == null
                  ? Center(
                      child: Text(
                        hasConfiguredStream
                            ? (widget.enableNativePlayer ? (_error ?? 'Lecteur indisponible') : 'Aperçu vidéo désactivé pour le test')
                            : 'Aucun flux configuré',
                        style: const TextStyle(color: Color(0xFF91A4BB)),
                      ),
                    )
                  : VlcPlayer(
                      controller: controller,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(child: CircularProgressIndicator()),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(available ? 'LIVE' : 'INDISPONIBLE')),
              Chip(label: Text(widget.camera.family)),
              if (widget.camera.location.isNotEmpty) Chip(label: Text(widget.camera.location)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ControlButton(icon: _muted ? Icons.volume_off : Icons.volume_up, label: 'Écouter', enabled: available, onTap: _toggleMute),
              _ControlButton(icon: Icons.mic, label: 'Parler', enabled: false, onTap: () => _unsupported('Parler')),
              _ControlButton(icon: Icons.photo_camera, label: 'Photo', enabled: available, onTap: _snapshot),
              _ControlButton(icon: _recording ? Icons.stop_circle : Icons.fiber_manual_record, label: 'REC', enabled: available, onTap: _toggleRecording),
              _ControlButton(icon: Icons.control_camera, label: 'PTZ', enabled: false, onTap: () => _unsupported('PTZ')),
              _ControlButton(icon: Icons.fullscreen, label: 'Plein écran', enabled: available, onTap: _toggleFullscreen),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.label, required this.enabled, required this.onTap});

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
