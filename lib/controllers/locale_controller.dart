import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier with WidgetsBindingObserver {
  LocaleController({Locale? initialLocale})
      : _userLocale = initialLocale,
        _systemLocale = WidgetsBinding.instance.platformDispatcher.locale {
    WidgetsBinding.instance.addObserver(this);
  }

  Locale? _userLocale;
  Locale _systemLocale;

  Locale? get locale => _userLocale ?? _systemLocale;

  void updateLocale(Locale? locale) {
    if (_userLocale == locale) {
      return;
    }
    _userLocale = locale;
    notifyListeners();
  }

  void clearLocale() {
    if (_userLocale == null) {
      return;
    }
    _userLocale = null;
    notifyListeners();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final Locale? newLocale =
        (locales != null && locales.isNotEmpty) ? locales.first : null;
    final Locale resolvedLocale =
        newLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
    if (resolvedLocale == _systemLocale) {
      return;
    }
    _systemLocale = resolvedLocale;
    if (_userLocale == null) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static LocaleController of(BuildContext context) {
    final LocaleScope? scope =
        context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null,
        'LocaleScope.of() called with a context that does not contain a LocaleScope.');
    final LocaleController? controller = scope?.notifier;
    if (controller == null) {
      throw StateError(
        'LocaleScope.of() called with a LocaleScope that has a null notifier.',
      );
    }
    return controller;
  }

  static LocaleController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleScope>()
        ?.notifier;
  }
}
