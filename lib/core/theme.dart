import 'package:flutter/material.dart';

class AppTheme {
  static final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF680C07)),
    useMaterial3: true,
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: const Color(0xFF680C07),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(             
        color: Colors.white,                 
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
