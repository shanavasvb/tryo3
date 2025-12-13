import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryo3_app/providers/theme_provider.dart';
import 'package:tryo3_app/screens/landing_screen.dart';
import 'package:tryo3_app/themes/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state to trigger rebuilds when it changes
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    
    return MaterialApp(
      title: 'tryo3 App',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeModeNotifier.themeMode,
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

