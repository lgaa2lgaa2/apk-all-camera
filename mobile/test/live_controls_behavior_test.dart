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

    expect(find.text('Écouter'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Plein écran'), findsOneWidget);
    expect(find.text('Parler'), findsOneWidget);
    expect(find.text('REC'), findsOneWidget);
    expect(find.text('PTZ'), findsOneWidget);
  });
}
