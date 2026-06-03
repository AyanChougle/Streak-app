import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF1C1C1E);
  static const surfaceElevated = Color(0xFF2C2C2E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const accent = Color(0xFF0A84FF);
  static const accentDim = Color(0xFF0A84FF);
  static const destructive = Color(0xFFFF453A);
  static const success = Color(0xFF32D74B);
  static const separator = Color(0xFF38383A);
  static const streakOrange = Color(0xFFFF9F0A);
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark();

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.destructive,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.inter(
        color: AppColors.accent,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.accent),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.separator,
      thickness: 0.5,
      space: 0,
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.surface,
      iconColor: AppColors.accent,
      textColor: AppColors.textPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 54),
        textStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.textSecondary),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.surfaceElevated),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
