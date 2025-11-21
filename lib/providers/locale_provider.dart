import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/locale_controller.dart';

/// Provider for LocaleController
final localeControllerProvider = ChangeNotifierProvider<LocaleController>((ref) {
  return LocaleController();
});

/// Provider for current locale
final currentLocaleProvider = Provider<Locale?>((ref) {
  return ref.watch(localeControllerProvider).locale;
});
