import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/widgets/app_shell.dart';

void main() {
  testWidgets('shell exposes primary destinations', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));

    expect(find.text('Caméras'), findsWidgets);
    expect(find.text('Ajouter'), findsWidgets);
    expect(find.text('Alertes'), findsWidgets);
    expect(find.text('Stockage'), findsWidgets);
    expect(find.text('Utilisateurs'), findsWidgets);
    expect(find.text('Réglages'), findsWidgets);
  });
}
