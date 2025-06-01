import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Ubuntu',

  // Scaffold background
  scaffoldBackgroundColor: const Color(0xFF0A1B2E),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0A1B2E),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: 'Ubuntu-Bold',
    ),
  ),

  // Elevated Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0A1B2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundColor: Colors.white,
    ),
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.amber,
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // TextField stylingQ
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200], // ✅ Light grey background
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintStyle: TextStyle(color: Colors.black45),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.deepPurple, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.transparent),
    ),
  ),
);