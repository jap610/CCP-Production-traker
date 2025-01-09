// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_page.dart';

void main() {
  runApp(
    // Initialize the ThemeProvider
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ExcelReaderApp(),
    ),
  );
}

/// **ExcelReaderApp** is the root widget of the application
class ExcelReaderApp extends StatelessWidget {
  const ExcelReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Production Tracker',
      theme: Provider.of<ThemeProvider>(context).getTheme(),
      home: const ExcelReaderHomePage(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}
