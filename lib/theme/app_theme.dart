import 'package:flutter/material.dart';

class AppTheme {
  // Kiwi color
  static const Color primary = Color(0xFF8EE53F); // Kiwi green

  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFF44336);
  static const Color textLight = Colors.white;
  static const Color textDark = Colors.black87;

  static const String fontFamily = 'Roboto';

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(primary),
      trackColor: MaterialStateProperty.all(primary.withOpacity(0.4)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(primary),
      trackColor: MaterialStateProperty.all(primary.withOpacity(0.4)),
    ),
  );
}
