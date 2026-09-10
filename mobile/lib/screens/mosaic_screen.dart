import 'package:flutter/material.dart';
import '../models/camera.dart';

class MosaicScreen extends StatelessWidget {
  const MosaicScreen({super.key, required this.cameras});
  final List<CameraDevice> cameras;

  @override
  Widget build(BuildContext context) {
    final slots = List<CameraDevice?>.generate(4, (index) => index < cameras.length ? cameras[index] : null);
    return Scaffold(
      appBar: AppBar(title: const Text('Mosaïque 2×2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final camera = slots[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1D30),
                border: Border.all(color: const Color(0xFF203751)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: camera == null
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_outlined, size: 38, color: Color(0xFF4FD6FF)),
                          SizedBox(height: 8),
                          Text('Emplacement caméra'),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam, size: 38, color: Color(0xFF4FD6FF)),
                            const SizedBox(height: 8),
                            Text(camera.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(camera.location.isEmpty ? camera.family : camera.location, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF91A4BB))),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
