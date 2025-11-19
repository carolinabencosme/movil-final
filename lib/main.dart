import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'controllers/auth_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/locale_controller.dart';
import 'graphql_config.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_repository.dart';
import 'services/favorites_repository.dart';
import 'services/pokemon_cache_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  final clientNotifier = await initGraphQLClient();
  final pokemonCacheService = await PokemonCacheService.init();
  final themeController = ThemeController();
  final localeController = LocaleController();
  final authRepository = await AuthRepository.init();
  final authController = AuthController(repository: authRepository);
  final favoritesRepository = await FavoritesRepository.init(pokemonCacheService);
  final favoritesController =
      FavoritesController(repository: favoritesRepository);

  runApp(
    MyApp(
      clientNotifier: clientNotifier,
      themeController: themeController,
      localeController: localeController,
      authController: authController,
      favoritesController: favoritesController,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.clientNotifier,
    required this.themeController,
    required this.localeController,
    required this.authController,
    required this.favoritesController,
  });

  final ValueNotifier<GraphQLClient> clientNotifier;
  final ThemeController themeController;
  final LocaleController localeController;
  final AuthController authController;
  final FavoritesController favoritesController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.themeController.dispose();
    widget.localeController.dispose();
    widget.authController.dispose();
    widget.favoritesController.dispose();
    widget.clientNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = widget.themeController;
    final authController = widget.authController;
    final favoritesController = widget.favoritesController;

    return ThemeScope(
      notifier: themeController,
      child: LocaleScope(
        notifier: widget.localeController,
        child: AuthScope(
          notifier: authController,
          child: FavoritesScope(
            notifier: favoritesController,
            child: AnimatedBuilder(
              animation: Listenable.merge(
                [themeController, widget.localeController],
              ),
              builder: (context, _) {
                final localizations = AppLocalizations.of(context);
                return GraphQLProvider(
                  client: widget.clientNotifier,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: localizations?.appTitle ?? 'Pokédex GraphQL',
                    themeMode: themeController.themeMode,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    locale: widget.localeController.locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    home: AuthGate(controller: authController),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
