import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_controller.dart';

/// Provider for ThemeController
final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});

/// Provider for theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeControllerProvider).themeMode;
});

/// Provider to check if dark mode is enabled
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeControllerProvider).isDarkMode;
});
