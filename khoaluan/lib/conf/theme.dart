import 'package:flutter/material.dart';

class AppStyles {
  // Global font family (Defaults to system font like Roboto, Segoe UI, etc.)
  static const String fontFamily = 'sans-serif';

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4E73DF),
    primary: const Color(0xFF4E73DF),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: AppStyles.fontFamily),
    displayMedium: TextStyle(fontFamily: AppStyles.fontFamily),
    displaySmall: TextStyle(fontFamily: AppStyles.fontFamily),
    headlineLarge: TextStyle(fontFamily: AppStyles.fontFamily),
    headlineMedium: TextStyle(fontFamily: AppStyles.fontFamily),
    headlineSmall: TextStyle(fontFamily: AppStyles.fontFamily),
    titleLarge: AppStyles.titleLarge,
    titleMedium: AppStyles.titleMedium,
    bodyLarge: AppStyles.bodyLarge,
    bodyMedium: AppStyles.bodyMedium,
    bodySmall: AppStyles.bodySmall,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF4E73DF), width: 2),
    ),
    floatingLabelStyle: TextStyle(color: Color(0xFF4E73DF)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return null;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF4E73DF);
      }
      return null;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF4E73DF);
      }
      return null;
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF4E73DF);
      }
      return null;
    }),
  ),
);
