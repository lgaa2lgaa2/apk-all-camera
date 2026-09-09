import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/screens/add_camera_screen.dart';

void main() {
  testWidgets('premium add camera screen exposes setup methods and automatic discovery', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCameraScreen()));

    expect(find.text('QR code'), findsOneWidget);
    expect(find.text('Son / bip-bip'), findsOneWidget);
    expect(find.text('Bluetooth'), findsOneWidget);
    expect(find.text('Wi-Fi AP'), findsOneWidget);
    expect(find.text('ONVIF / RTSP'), findsOneWidget);
    expect(find.text('Ajout manuel'), findsOneWidget);
    expect(find.text('Scanner les caméras'), findsOneWidget);
    expect(find.text('Adresse du flux'), findsNothing);
  });
}
