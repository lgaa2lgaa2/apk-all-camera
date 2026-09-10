import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/camera.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.camera});
  final CameraDevice camera;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VlcPlayerController? _controller;
  String? _error;
  bool _muted = false;
  bool _recording = false;
  bool _fullscreen = false;

  bool get _nativePlayerAvailable => !kIsWeb;

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
    } catch (error) {
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
    final available = controller != null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.camera.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: Colors.black,
                child: available
                    ? VlcPlayer(
                        controller: controller,
                        aspectRatio: 16 / 9,
                        placeholder: const Center(child: CircularProgressIndicator()),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _error ?? (_nativePlayerAvailable ? 'Flux vidéo indisponible.' : 'Lecteur vidéo natif indisponible dans cet environnement.'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: available ? Colors.green.withValues(alpha: 0.18) : Colors.red.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(available ? 'LIVE' : 'INDISPONIBLE'),
              ),
              const Spacer(),
              Text(widget.camera.location),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ControlButton(icon: _muted ? Icons.volume_off : Icons.volume_up, label: 'Écouter', onPressed: available ? _toggleMute : null),
              _ControlButton(icon: Icons.camera_alt, label: 'Photo', onPressed: available ? _snapshot : null),
              _ControlButton(icon: Icons.fullscreen, label: 'Plein écran', onPressed: available ? _toggleFullscreen : null),
              _ControlButton(icon: Icons.mic, label: 'Parler', onPressed: available ? () => _unsupported('Parler') : null),
              _ControlButton(icon: _recording ? Icons.stop_circle : Icons.fiber_manual_record, label: 'REC', onPressed: available ? _toggleRecording : null),
              _ControlButton(icon: Icons.control_camera, label: 'PTZ', onPressed: available ? () => _unsupported('PTZ') : null),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
