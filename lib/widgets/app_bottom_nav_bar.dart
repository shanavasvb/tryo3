import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/screens/dashboard_screen.dart';
import 'package:tryo3_app/screens/history_screen.dart';

/// Reusable bottom navigation bar for the app.
///
/// Provides navigation between Dashboard, History, and Settings screens.
class AppBottomNavBar extends StatelessWidget {
  /// The currently active navigation index (0: Dashboard, 1: History, 2: Settings)
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final manropeFont = GoogleFonts.manrope().fontFamily;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedLabelStyle: TextStyle(fontFamily: manropeFont),
      unselectedLabelStyle: TextStyle(fontFamily: manropeFont),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
      onTap: (index) => _handleNavigation(context, index),
    );
  }

  /// Handle navigation tap
  void _handleNavigation(BuildContext context, int index) {
    // Don't navigate if already on the selected screen
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        // Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
      case 1:
        // Navigate to History
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
        break;
      case 2:
        // TODO: Navigate to Settings
        debugPrint('Settings selected');
        break;
    }
  }
}
