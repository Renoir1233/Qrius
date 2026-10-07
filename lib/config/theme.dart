import 'package:flutter/material.dart';

// University of Mindanao official colors
const Color Maroon = Color(0xFF800020); // Main maroon color
const Color umLightMaroon = Color(0xFFA52A45); // Lighter maroon for accents
const Color umSoftMaroon = Color(
  0xFFB8405E,
); // Softer maroon for backgrounds (eye-friendly)
const Color umPaleMaroon = Color(
  0xFFF5E6E8,
); // Very light maroon for backgrounds

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,

  //scafffold bk color
  scaffoldBackgroundColor: umPaleMaroon,
  //appbar theme - maroon bg, white text and icons everywhere
  appBarTheme: const AppBarTheme(
    backgroundColor: Maroon,
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  //colorscheme
  colorScheme: ColorScheme.light(
    primary: umPaleMaroon, //scaffoldbc
    secondary: umSoftMaroon, //cards
    onPrimary: Colors.black, //texts
    onSecondary: Colors.white, //textfields/card
    onSecondaryContainer: Maroon, //signbuttons
    onPrimaryContainer: Colors.teal, //student role
    onPrimaryFixed: Colors.grey, //svg nav
    onSecondaryFixed: Maroon, //appbar
    onSecondaryFixedVariant: Colors.grey.shade50, //textfield signup
    onSurfaceVariant: Colors.black, //notification text
  ),
);
ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,

  //scaffold bk color
  scaffoldBackgroundColor: Colors.grey.shade900,
  //appbar theme - dark bg, white text and icons
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
    actionsIconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  //colorscheme
  colorScheme: ColorScheme.dark(
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade800,
    onPrimary: Colors.grey.shade300,
    onSecondary: Colors.grey.shade800,
    onSecondaryContainer: umLightMaroon,
    onPrimaryContainer: Colors.teal,
    onPrimaryFixed: Colors.grey,
    onSecondaryFixed: Colors.grey.shade900,
    onSecondaryFixedVariant: Colors.grey.shade900,
    onSurfaceVariant: Colors.white, //notification text
  ),
);
