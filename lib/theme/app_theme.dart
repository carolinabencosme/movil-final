import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static final ThemeData light = _buildTheme(_lightColorScheme);
  static final ThemeData dark = _buildTheme(_darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    final textTheme = baseTheme.textTheme
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        )
        .copyWith(
          headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: colorScheme.outline.withOpacity(0.3),
      ),
    );

    final bool isDark = colorScheme.brightness == Brightness.dark;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: baseTheme.iconTheme.copyWith(
          color: colorScheme.onBackground,
        ),
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        elevation: isDark ? 3 : 2,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.35)
            : Colors.black.withOpacity(0.12),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: colorScheme.surfaceVariant,
        disabledColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        iconTheme: baseTheme.iconTheme.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        showCheckmark: false,
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: inputBorder,
        enabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
      textTheme: textTheme,
      useMaterial3: true,
    );
  }
}

const ColorScheme _darkColorScheme = ColorScheme.dark(
  primary: Color(0xFFE94256),
  onPrimary: Colors.white,
  secondary: Color(0xFFF2A649),
  onSecondary: Color(0xFF111118),
  tertiary: Color(0xFF4DA3FF),
  onTertiary: Color(0xFF021326),
  background: Color(0xFF0B0B0F),
  onBackground: Colors.white,
  surface: Color(0xFF16161D),
  onSurface: Color(0xFFE6E6F0),
  surfaceVariant: Color(0xFF1F1F28),
  onSurfaceVariant: Color(0xFFCACAD6),
  error: Color(0xFFFF6B6B),
  onError: Colors.black,
  outline: Color(0xFF30303A),
);

const ColorScheme _lightColorScheme = ColorScheme.light(
  primary: Color(0xFFE94256),
  onPrimary: Colors.white,
  secondary: Color(0xFFF2A649),
  onSecondary: Color(0xFF2C1400),
  tertiary: Color(0xFF4DA3FF),
  onTertiary: Color(0xFF04203F),
  background: Color(0xFFF5F6FB),
  onBackground: Color(0xFF191921),
  surface: Colors.white,
  onSurface: Color(0xFF20202A),
  surfaceVariant: Color(0xFFE5E6F2),
  onSurfaceVariant: Color(0xFF4C4C5C),
  error: Color(0xFFBA1A1A),
  onError: Colors.white,
  outline: Color(0xFFCACAD6),
);
