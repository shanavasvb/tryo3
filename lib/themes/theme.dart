import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme{
  // light theme colors
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightTextColor = Color(0xFF000000);
  static const lightbtnColor = Color(0xFFD7F2C5);

  // dark theme colors
  static const darkBackground = Color(0xFF060E10);
  static const darkTextColor = Color(0xFFFFFFFF);
  static const darkbtnColor = Color(0xFF2D5F4D);

  //shared colors
  static const primaryColor = Color(0xFF2D5F4D);
  static const accentColor = Color(0xFFB2DFDB);

  static ThemeData lightTheme(){
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: lightTextColor,
        displayColor: lightTextColor,
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightbtnColor,
          foregroundColor: darkTextColor,
        ),
      ),
    );
    
  }
  static ThemeData darkTheme(){
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkbtnColor,
          foregroundColor: darkTextColor,
        ),
      ),
    );
    
  }
}