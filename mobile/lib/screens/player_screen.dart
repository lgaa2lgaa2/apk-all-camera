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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.camera.name)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                      )
                    : VlcPlayer(
                        controller: _controller!,
                        aspectRatio: 16 / 9,
                        placeholder: const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(widget.camera.family),
              subtitle: Text(widget.camera.location.isEmpty ? widget.camera.streamUrl : widget.camera.location),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _controller == null ? null : () async {
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
