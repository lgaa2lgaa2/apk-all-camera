import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/camera.dart';
import 'package:apk_all_camera/screens/player_screen.dart';

void main() {
  testWidgets('unsupported vendor controls are visibly unavailable in widget tests', (tester) async {
    const camera = CameraDevice(
      id: '1',
      name: 'Test camera',
      family: 'Generic RTSP',
      streamUrl: 'rtsp://192.168.1.20:554/stream1',
      connectionType: CameraConnectionType.rtsp,
    );

    await tester.pumpWidget(const MaterialApp(home: PlayerScreen(camera: camera)));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;

    for (final label in ['Écouter', 'Photo', 'Plein écran', 'Parler', 'REC', 'PTZ']) {
      await tester.scrollUntilVisible(find.text(label), 200, scrollable: scrollable);
      expect(find.text(label), findsOneWidget);
    }
  });
}
