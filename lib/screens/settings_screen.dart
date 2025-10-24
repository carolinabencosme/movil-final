import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../theme/theme_controller.dart';
import 'profile_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);
    final themeController = ThemeScope.of(context);
    final themeMode = themeController.themeMode;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
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
                    'Cuenta',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.currentEmail ?? 'Sin correo registrado',
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
                          child: const Text('Editar perfil'),
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
                          child: const Text('Cerrar sesión'),
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
            'Apariencia',
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
                  title: 'Modo claro',
                  subtitle:
                      'Fondos luminosos ideales para entornos bien iluminados.',
                  icon: Icons.light_mode_outlined,
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: themeController.updateThemeMode,
                ),
                const Divider(height: 0),
                _ThemeOptionTile(
                  title: 'Modo oscuro',
                  subtitle:
                      'Atenúa la luz para reducir el cansancio visual por la noche.',
                  icon: Icons.dark_mode_outlined,
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: themeController.updateThemeMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'La configuración se guarda inmediatamente y afecta a toda la aplicación.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
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
