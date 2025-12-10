import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/screens/dashboard_screen.dart';

/// Landing screen that displays the app introduction and get started button.
///
/// This screen is the first screen users see when opening the app.
/// It features:
/// - App branding (logo and tagline)
/// - Hero image showcasing the app's theme
/// - Call-to-action button to proceed to main app
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // Design tokens
  static const double _horizontalPadding = 24.0;
  static const double _imageBorderRadius = 16.0;
  static const double _buttonHeight = 56.0;
  static const double _spacing = 16.0;

  // Asset paths
  static const String _plantImagePath = 'assets/images/plant.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final manropeFont = GoogleFonts.manrope().fontFamily;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // App logo/title
              _buildAppTitle(textColor, manropeFont),

              const SizedBox(height: _spacing),

              // Tagline
              _buildTagline(textColor, manropeFont),

              const SizedBox(height: 40),

              // Hero image
              Expanded(child: _buildHeroImage(theme, textColor)),

              const SizedBox(height: 30),

              // CTA Button
              _buildGetStartedButton(manropeFont),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the app title "tryo3"
  Widget _buildAppTitle(Color textColor, String? fontFamily) {
    return Text(
      'tryo3',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Builds the tagline below the title
  Widget _buildTagline(Color textColor, String? fontFamily) {
    return Text(
      'For people who love air.',
      style: TextStyle(
        fontSize: 16,
        color: textColor.withOpacity(0.7),
        fontFamily: fontFamily,
      ),
    );
  }

  /// Builds the hero image container with proper styling
  Widget _buildHeroImage(ThemeData theme, Color textColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF4A6358),
        borderRadius: BorderRadius.circular(_imageBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_imageBorderRadius),
        child: Image.asset(
          _plantImagePath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget(theme, textColor);
          },
        ),
      ),
    );
  }

  /// Builds error widget shown when image fails to load
  Widget _buildImageErrorWidget(ThemeData theme, Color textColor) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 64,
              color: textColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Image not available',
              style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "Get Started" call-to-action button
  Widget _buildGetStartedButton(String? fontFamily) {
    return Builder(
      builder: (context) => SizedBox(
        width: 150,
        height: _buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () => _handleGetStarted(context),
          child: Text(
            'Get Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  /// Handles the "Get Started" button press
  void _handleGetStarted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }
}
