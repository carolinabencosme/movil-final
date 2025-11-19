import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/auth_controller.dart';
import '../controllers/locale_controller.dart';
import '../theme/theme_controller.dart';
import 'profile_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Locale> _languageOptions = [
    Locale('es'),
    Locale('en'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = AuthScope.of(context);
    final themeController = ThemeScope.of(context);
    final themeMode = themeController.themeMode;
    final textTheme = Theme.of(context).textTheme;
    final localeController = LocaleScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsAccountSection,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.currentEmail ?? l10n.settingsNoEmail,
                    style: textTheme.bodyLarge,
                  ),
                  if (controller.isLoading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: controller.currentEmail == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileSettingsScreen(
                                        controller: controller,
                                      ),
                                    ),
                                  );
                                },
                          child: Text(l10n.settingsEditProfile),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final navigator = Navigator.of(context);
                                  await controller.logout();
                                  if (!navigator.mounted) {
                                    return;
                                  }
                                  navigator.pop();
                                },
                          child: Text(l10n.settingsSignOut),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsAppearanceSection,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeOptionTile(
                  title: l10n.settingsLightModeTitle,
                  subtitle: l10n.settingsLightModeSubtitle,
                  icon: Icons.light_mode_outlined,
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: themeController.updateThemeMode,
                ),
                const Divider(height: 0),
                _ThemeOptionTile(
                  title: l10n.settingsDarkModeTitle,
                  subtitle: l10n.settingsDarkModeSubtitle,
                  icon: Icons.dark_mode_outlined,
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: themeController.updateThemeMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: localeController,
            builder: (context, _) {
              final selectedLanguageCode =
                  localeController.locale?.languageCode;
              Locale? selectedLocale;
              for (final locale in _languageOptions) {
                if (locale.languageCode == selectedLanguageCode) {
                  selectedLocale = locale;
                  break;
                }
              }
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsLanguageSection,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Locale>(
                        value: selectedLocale,
                        decoration: InputDecoration(
                          labelText: l10n.settingsLanguageLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: _languageOptions
                            .map(
                              (locale) => DropdownMenuItem<Locale>(
                                value: locale,
                                child: Text(
                                  _languageLabel(locale, l10n),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (locale) {
                          if (locale != null) {
                            localeController.updateLocale(locale);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsInfo,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  static String _languageLabel(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'es':
        return l10n.settingsLanguageSpanish;
      case 'en':
      default:
        return l10n.settingsLanguageEnglish;
    }
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: (mode) {
        if (mode != null) {
          onChanged(mode);
        }
      },
      activeColor: colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: colorScheme.primary),
    );
  }
}
