import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/screens/mosaic_screen.dart';
import 'package:apk_all_camera/screens/permissions_screen.dart';
import 'package:apk_all_camera/screens/settings_screen.dart';
import 'package:apk_all_camera/screens/admin_screen.dart';
import 'package:apk_all_camera/screens/system_status_screen.dart';
import 'package:apk_all_camera/screens/distribution_screen.dart';

void main() {
  testWidgets('mosaic exposes four camera slots', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MosaicScreen(cameras: [])));
    expect(find.text('Mosaïque 2×2'), findsOneWidget);
    expect(find.text('Emplacement caméra'), findsNWidgets(4));
  });

  testWidgets('permissions screen exposes access controls', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PermissionsScreen()));
    expect(find.text('Caméras autorisées'), findsOneWidget);
    expect(find.text('Droits'), findsOneWidget);
    expect(find.text('Accès temporaire'), findsOneWidget);
  });

  testWidgets('settings admin system and distribution labels exist', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    expect(find.text('Vidéo sur 4G/5G'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: AdminScreen()));
    expect(find.text('Panel Admin'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SystemStatusScreen()));
    expect(find.text('HTTPS / TLS'), findsOneWidget);
    expect(find.text('État système'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: DistributionScreen()));
    expect(find.text('Android'), findsOneWidget);
    expect(find.text('iPhone'), findsOneWidget);
  });
}
