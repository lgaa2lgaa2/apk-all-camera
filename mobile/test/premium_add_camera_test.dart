import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/discovery_compatibility.dart';
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

  test('compatibility labels are explicit and user-facing', () {
    expect(AddCameraScreen.compatibilityLabel(DiscoveryCompatibilityStatus.compatible), 'Compatible');
    expect(AddCameraScreen.compatibilityLabel(DiscoveryCompatibilityStatus.authenticationRequired), 'Authentification requise');
    expect(AddCameraScreen.compatibilityLabel(DiscoveryCompatibilityStatus.partial), 'Partiel');
    expect(AddCameraScreen.compatibilityLabel(DiscoveryCompatibilityStatus.proprietaryUnsupported), 'Propriétaire/non pris en charge');
    expect(AddCameraScreen.compatibilityLabel(DiscoveryCompatibilityStatus.unavailable), 'Indisponible');
  });
}
