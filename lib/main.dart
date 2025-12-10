import 'package:flutter/material.dart';
import 'package:tryo3_app/screens/landing_screen.dart';
import 'package:tryo3_app/themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tryo3 App',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

