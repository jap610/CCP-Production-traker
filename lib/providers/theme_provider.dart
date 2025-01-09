// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';

/// **ThemeProvider** to manage light and dark themes
class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider()
      : _themeData = ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0142AB), // Dark Blue
          hintColor: const Color(0xFFF79009), // Orange
          scaffoldBackgroundColor: Colors.black,
          textTheme: const TextTheme(
            titleLarge:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey,
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        );

  ThemeData getTheme() => _themeData;

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      _themeData = ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0142AB),
        hintColor: const Color(0xFFF79009),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          titleLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      );
    } else {
      _themeData = ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0142AB),
        hintColor: const Color(0xFFF79009),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      );
    }
    notifyListeners();
  }
}
