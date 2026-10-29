// Polarsteps v2 — 여행 기록 UI 프로토타입
import 'package:flutter/material.dart';
import 'screens/a_list_screen.dart';
import 'destinations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadDestinations();
  runApp(const MidProjectApp());
}

class MidProjectApp extends StatelessWidget {
  const MidProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF183B3A);
    const teal = Color(0xFF2D7770);
    return MaterialApp(
      title: 'Polarsteps v2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F5),
          foregroundColor: ink,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
          titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        ),
      ),
      home: const ListScreen(),
    );
  }
}
