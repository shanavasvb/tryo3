import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/providers/theme_provider.dart';
import 'package:tryo3_app/themes/theme.dart';
import 'package:tryo3_app/widgets/app_bottom_nav_bar.dart';

/// Settings screen with app preferences and account management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(isDark, 'General'),
            const SizedBox(height: 12),
            _buildThemeRow(isDark),
            const SizedBox(height: 8),
            _buildNotificationsRow(isDark),
            
            const SizedBox(height: 32),
            _buildSectionHeader(isDark, 'My Devices'),
            const SizedBox(height: 12),
            _buildNavigationRow(
              isDark: isDark,
              title: 'Manage Sensors',
              onTap: () => _showComingSoon('Manage Sensors'),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader(isDark, 'Account'),
            const SizedBox(height: 12),
            _buildNavigationRow(
              isDark: isDark,
              title: 'Profile',
              onTap: () => _showComingSoon('Profile'),
            ),
            const SizedBox(height: 8),
            _buildNavigationRow(
              isDark: isDark,
              title: 'Change Password',
              onTap: () => _showComingSoon('Change Password'),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader(isDark, 'About'),
            const SizedBox(height: 12),
            _buildNavigationRow(
              isDark: isDark,
              title: 'About Oxy Oxy Onyx',
              onTap: () => _showComingSoon('About'),
            ),
            const SizedBox(height: 8),
            _buildNavigationRow(
              isDark: isDark,
              title: 'Privacy Policy',
              onTap: () => _showComingSoon('Privacy Policy'),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Settings',
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
      ),
    );
  }

  Widget _buildThemeRow(bool isDark) {
    final themeModeNotifier = ref.watch(themeModeProvider.notifier);
    final themeName = themeModeNotifier.themeName;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                themeName,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                      .withOpacity(0.5),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showThemeDialog(isDark),
            child: Text(
              themeName,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                    .withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _notificationsEnabled ? 'On' : 'Off',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                      .withOpacity(0.5),
                ),
              ),
            ],
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required bool isDark,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                  .withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Theme',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(isDark, 'System'),
            _buildThemeOption(isDark, 'Light'),
            _buildThemeOption(isDark, 'Dark'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(bool isDark, String theme) {
    final themeModeNotifier = ref.watch(themeModeProvider.notifier);
    final currentTheme = themeModeNotifier.themeName;
    final isSelected = currentTheme == theme;
    
    return InkWell(
      onTap: () {
        // Update theme based on selection
        switch (theme) {
          case 'System':
            themeModeNotifier.setThemeMode(AppThemeMode.system);
            break;
          case 'Light':
            themeModeNotifier.setThemeMode(AppThemeMode.light);
            break;
          case 'Dark':
            themeModeNotifier.setThemeMode(AppThemeMode.dark);
            break;
        }
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                      .withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              theme,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Coming Soon',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
            ),
          ),
          content: Text(
            '$feature feature will be available in a future update.',
            style: GoogleFonts.manrope(
              color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
