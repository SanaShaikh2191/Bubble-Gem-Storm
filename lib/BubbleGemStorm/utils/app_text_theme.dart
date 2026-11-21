import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontSize: 18,
     
      fontWeight: FontWeight.w900,
      color: Colors.white,
    ),

    displayLarge: TextStyle(
      fontSize: 36,
      
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 2,
    ),
    titleLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      
      color: Colors.white,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      
      color: Colors.white,
    ),
  );
}
