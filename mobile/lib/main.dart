import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AllCameraApp());
}

class AllCameraApp extends StatelessWidget {
  const AllCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APK All Camera',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
