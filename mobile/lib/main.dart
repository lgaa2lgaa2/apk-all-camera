import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AllCameraApp());
}

class AllCameraApp extends StatelessWidget {
  const AllCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF07111F);
    const panel = Color(0xFF0F1D30);
    const blue = Color(0xFF2F8CFF);
    const cyan = Color(0xFF4FD6FF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APK All Camera',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: blue,
          secondary: cyan,
          surface: panel,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF203751)),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF091725),
          labelStyle: const TextStyle(color: Color(0xFFB9C8D8)),
          hintStyle: const TextStyle(color: Color(0xFF6F849B)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF203751)),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: blue, width: 1.4),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
