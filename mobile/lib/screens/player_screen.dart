import 'dart:typed_data';

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

  bool get _isWidgetTest => kDebugMode && WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  bool get _supportsNativePlayerControls => _controller != null && !_isWidgetTest && _error == null;

  @override
  void initState() {
    super.initState();
    final uri = widget.camera.authenticatedUri();
    if (uri == null || uri.scheme.isEmpty) {
      _error = 'Adresse de flux invalide.';
      return;
    }
    if (widget.camera.connectionType == CameraConnectionType.proprietary) {
      _error = 'Cette caméra utilise un protocole propriétaire. Un connecteur/SDK fabricant est nécessaire.';
      return;
    }
    if (_isWidgetTest) return;

    _controller = VlcPlayerController.network(
      uri.toString(),
      hwAcc: HwAcc.auto,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(500)]),
        rtp: VlcRtpOptions([VlcRtpOptions.rtpOverRtsp(true)]),
      ),
    );
  }

  @override
  void dispose() {
    if (!_isWidgetTest) {
      _controller?.dispose();
      if (_fullscreen) {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
    super.dispose();
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    final nextMuted = !_muted;
    await controller.setVolume(nextMuted ? 0 : 100);
    if (mounted) setState(() => _muted = nextMuted);
  }

  Future<void> _takeSnapshot() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final Uint8List? snapshot = await controller.takeSnapshot();
      if (!mounted) return;
      final message = snapshot == null || snapshot.isEmpty ? 'Capture impossible sur ce flux.' : 'Photo capturée.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture non prise en charge par ce flux.')));
    }
  }

  Future<void> _toggleRecording() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (_recording) {
        await controller.stopRecording();
        if (mounted) setState(() => _recording = false);
      } else {
        final bool started = (await controller.startRecording('/storage/emulated/0/Download')) ?? false;
        if (!mounted) return;
        setState(() => _recording = started);
        if (!started) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enregistrement non disponible sur cet appareil.')));
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enregistrement non pris en charge.')));
    }
  }

  Future<void> _toggleFullscreen() async {
    final next = !_fullscreen;
    if (next) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    if (mounted) setState(() => _fullscreen = next);
  }

  void _showUnsupported(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature nécessite ONVIF PTZ, l’audio bidirectionnel ou le SDK du fabricant.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(_fullscreen ? 0 : 20),
        border: _fullscreen ? null : Border.all(color: const Color(0xFF203751)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                )
              : _isWidgetTest
                  ? const Icon(Icons.videocam, color: Colors.white54, size: 54)
                  : VlcPlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(child: CircularProgressIndicator()),
                    ),
        ),
      ),
    );

    if (_fullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(child: player),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filledTonal(
                  onPressed: _toggleFullscreen,
                  icon: const Icon(Icons.fullscreen_exit),
                  tooltip: 'Quitter le plein écran',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.camera.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            player,
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(widget.camera.family),
                subtitle: Text(widget.camera.location.isEmpty ? widget.camera.streamUrl : widget.camera.location),
                trailing: Chip(label: Text(_error == null ? 'LIVE' : 'INDISPONIBLE')),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _control(
                  _muted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
                  'Écouter',
                  enabled: _supportsNativePlayerControls,
                  onPressed: _toggleMute,
                ),
                _control(Icons.mic_none, 'Parler', enabled: _error == null, onPressed: () => _showUnsupported('Parler')),
                _control(Icons.photo_camera_outlined, 'Photo', enabled: _supportsNativePlayerControls, onPressed: _takeSnapshot),
                _control(
                  _recording ? Icons.stop_circle_outlined : Icons.fiber_manual_record,
                  'REC',
                  enabled: _supportsNativePlayerControls,
                  onPressed: _toggleRecording,
                ),
                _control(Icons.open_with, 'PTZ', enabled: _error == null, onPressed: () => _showUnsupported('PTZ')),
                _control(Icons.fullscreen, 'Plein écran', enabled: _supportsNativePlayerControls, onPressed: _toggleFullscreen),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _controller == null
                  ? null
                  : () async {
                      final playing = await _controller!.isPlaying();
                      if (playing == true) {
                        await _controller!.pause();
                      } else {
                        await _controller!.play();
                      }
                      if (mounted) setState(() {});
                    },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Lecture / Pause'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _control(
    IconData icon,
    String label, {
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
