import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.dark})
      : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void updateThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null,
        'ThemeScope.of() called with a context that does not contain a ThemeScope.');
    if (scope == null) {
      throw StateError(
        'ThemeScope.of() called with a context that does not contain a ThemeScope.',
      );
    }

    final controller = scope.notifier;
    if (controller == null) {
      throw StateError(
        'ThemeScope.of() called with a ThemeScope that has a null notifier.',
      );
    }

    return controller;
  }

  static ThemeController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeScope>()
        ?.notifier;
  }
}
