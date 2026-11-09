import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Famílias tipográficas empacotadas em assets/fonts.
class AppFonts {
  AppFonts._();

  static const display = 'BebasNeue';
  static const body = 'DMSans';
  static const mono = 'CourierPrime';
}

/// Estilos de texto reutilizados nas telas.
class AppText {
  AppText._();

  static TextStyle display(double size, {Color color = AppColors.azulMarinho}) =>
      TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size,
        height: 1,
        color: color,
      );

  static TextStyle eyebrow({Color color = AppColors.verdePetroleo}) => TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color,
      );

  static TextStyle mono(double size,
          {Color color = AppColors.azulMarinho,
          FontWeight weight = FontWeight.w700}) =>
      TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.azulMarinho,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.body,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        primary: AppColors.coral,
        secondary: AppColors.verdePetroleo,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: Color(0xFF7C8B97)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(AppColors.bordaInput),
        enabledBorder: _border(AppColors.bordaInput),
        focusedBorder: _border(AppColors.verdePetroleo, width: 2),
        errorBorder: _border(AppColors.coralEscuro),
        focusedErrorBorder: _border(AppColors.coralEscuro, width: 2),
        errorStyle: const TextStyle(color: AppColors.coralEscuro),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.verdePetroleo
              : null,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.azulMarinho,
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
}
