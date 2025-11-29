import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Define your color scheme as before
final colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.grey.shade600,
  brightness: Brightness.light,
  // You can override specific colors if you want more control
  primary: const Color(0xFF616161),      // For buttons and key actions (medium grey)
  surface: const Color(0xFFFAFAFA),      // Background of components like TextFields (off-white)
  onSurface: const Color(0xFF1a1a1a),    // Text color on top of surface (near black)
  surfaceContainerHighest: const Color(0xFFEEEEEE), // A slightly different surface color
);

// 2. Create the theme using the recommended ThemeData.from constructor
final appTheme =
    ThemeData.from(
      colorScheme: colorScheme,

      // Apply the base Ubuntu Condensed font theme
      textTheme: GoogleFonts.latoTextTheme(
        // It's good practice to start from the theme's default text theme
        ThemeData.light().textTheme,
      ),
    ).copyWith(
      // 3. Now, use .copyWith() to apply specific customizations on top
      scaffoldBackgroundColor: colorScheme.surface, // Example customization
      textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme)
          .copyWith(
            // Your specific overrides for bold titles
            titleSmall: GoogleFonts.lato(fontWeight: FontWeight.bold),
            titleMedium: GoogleFonts.lato(fontWeight: FontWeight.bold),
            titleLarge: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
    );


// --- ALTERNATIVE (also correct) ---
// You could also use ThemeData.light() which is very clear
/*
final appTheme = ThemeData.light(useMaterial3: true).copyWith(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme(
    ThemeData.light().textTheme,
  ).copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.ubuntuCondensed(fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.ubuntuCondensed(fontWeight: FontWeight.bold),
  ),
);
*/