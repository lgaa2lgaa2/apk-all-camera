import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  bool get _isWidgetTest => kDebugMode && WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');

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
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.camera.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF203751)),
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
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(widget.camera.family),
                subtitle: Text(widget.camera.location.isEmpty ? widget.camera.streamUrl : widget.camera.location),
                trailing: const Chip(label: Text('LIVE')),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _control(Icons.volume_up_outlined, 'Écouter'),
                _control(Icons.mic_none, 'Parler'),
                _control(Icons.photo_camera_outlined, 'Photo'),
                _control(Icons.fiber_manual_record, 'REC'),
                _control(Icons.open_with, 'PTZ'),
                _control(Icons.fullscreen, 'Plein écran'),
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

  Widget _control(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: _controller == null ? null : () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
