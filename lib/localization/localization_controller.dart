import 'package:flutter/material.dart';

class LocalizationController extends ChangeNotifier {
  LocalizationController({Locale? initialLocale}) : _locale = initialLocale;

  Locale? _locale;

  Locale? get locale => _locale;

  void updateLocale(Locale? locale) {
    if (_locale == locale ||
        (_locale != null &&
            locale != null &&
            _locale!.languageCode == locale.languageCode &&
            _locale!.countryCode == locale.countryCode)) {
      return;
    }

    _locale = locale;
    notifyListeners();
  }
}

class LocalizationScope extends InheritedNotifier<LocalizationController> {
  const LocalizationScope({
    super.key,
    required LocalizationController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static LocalizationController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocalizationScope>();
    assert(scope != null,
        'LocalizationScope.of() called with a context that does not contain LocalizationScope.');
    if (scope == null || scope.notifier == null) {
      throw StateError(
        'LocalizationScope.of() called with a context that does not contain LocalizationScope.',
      );
    }

    return scope.notifier!;
  }
}
