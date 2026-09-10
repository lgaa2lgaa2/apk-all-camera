import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/camera.dart';
import 'package:apk_all_camera/screens/player_screen.dart';

void main() {
  testWidgets('premium live view exposes camera controls', (tester) async {
    const camera = CameraDevice(
      id: '1',
      name: 'Salon',
      family: 'ONVIF',
      streamUrl: 'rtsp://192.168.1.50:554/stream1',
      connectionType: CameraConnectionType.rtsp,
      username: '',
      password: '',
      location: 'Salon',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PlayerScreen(camera: camera, enableNativePlayer: false),
      ),
    );
    await tester.pump();

    expect(find.text('Écouter', skipOffstage: false), findsOneWidget);
    expect(find.text('Parler', skipOffstage: false), findsOneWidget);
    expect(find.text('Photo', skipOffstage: false), findsOneWidget);
    expect(find.text('REC', skipOffstage: false), findsOneWidget);
    expect(find.text('PTZ', skipOffstage: false), findsOneWidget);
    expect(find.text('Plein écran', skipOffstage: false), findsOneWidget);
  });
}
