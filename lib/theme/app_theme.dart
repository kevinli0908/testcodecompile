import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    fontFamily: 'Roboto',
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color purpleAccent = Color(0xFF9C27B0);

  static const Color background = Color.fromARGB(255, 11, 16, 32);
  static const Color firstTitle = Color.fromARGB(255, 255, 255, 255);
  static const Color secondTitle = Color.fromARGB(128, 255, 255, 255);
  static const Color thirdTitle = Color.fromARGB(128, 255, 255, 255);

  static const Color ble_connect = Color.fromARGB(255, 74, 222, 128);
  static const Color ble_disconnect = Color.fromARGB(255, 248, 113, 113);

  static const Color ble_connect_bk = Color.fromARGB(15, 74, 222, 128);
  static const Color ble_disconnect_bk = Color.fromARGB(15, 248, 113, 113);

  static const EdgeInsets defaultPadding = EdgeInsets.all(20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
}