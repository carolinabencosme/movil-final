import 'package:flutter/material.dart';
import 'package:pokedex/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'controllers/auth_controller.dart';
import 'controllers/favorites_controller.dart';
import 'graphql_config.dart';
import 'localization/localization_controller.dart';
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
  final localizationController = LocalizationController();
  final authRepository = await AuthRepository.init();
  final authController = AuthController(repository: authRepository);
  final favoritesRepository = await FavoritesRepository.init(pokemonCacheService);
  final favoritesController =
      FavoritesController(repository: favoritesRepository);

  runApp(
    MyApp(
      clientNotifier: clientNotifier,
      themeController: themeController,
      localizationController: localizationController,
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
    required this.localizationController,
    required this.authController,
    required this.favoritesController,
  });

  final ValueNotifier<GraphQLClient> clientNotifier;
  final ThemeController themeController;
  final LocalizationController localizationController;
  final AuthController authController;
  final FavoritesController favoritesController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.themeController.dispose();
    widget.localizationController.dispose();
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

    final localizationController = widget.localizationController;

    return ThemeScope(
      notifier: themeController,
      child: LocalizationScope(
        notifier: localizationController,
        child: AuthScope(
          notifier: authController,
          child: FavoritesScope(
            notifier: favoritesController,
            child: AnimatedBuilder(
              animation: localizationController,
              builder: (context, __) {
                return AnimatedBuilder(
                  animation: themeController,
                  builder: (context, _) {
                    return GraphQLProvider(
                      client: widget.clientNotifier,
                      child: MaterialApp(
                        debugShowCheckedModeBanner: false,
                        onGenerateTitle: (context) =>
                            AppLocalizations.of(context)?.appTitle ??
                            'Pokédex GraphQL',
                        locale: localizationController.locale,
                        supportedLocales: AppLocalizations.supportedLocales,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        themeMode: themeController.themeMode,
                        theme: AppTheme.light,
                        darkTheme: AppTheme.dark,
                        home: AuthGate(controller: authController),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
