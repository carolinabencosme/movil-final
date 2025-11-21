import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'screens/detail_screen.dart';
import 'widgets/detail/detail_constants.dart';
import 'graphql_config.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_repository.dart';
import 'services/favorites_repository.dart';
import 'services/pokemon_cache_service.dart';
import 'services/trivia_repository.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/trivia_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  final clientNotifier = await initGraphQLClient();
  final pokemonCacheService = await PokemonCacheService.init();
  final authRepository = await AuthRepository.init();
  final favoritesRepository = await FavoritesRepository.init(pokemonCacheService);
  final triviaRepository = await TriviaRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        favoritesRepositoryProvider.overrideWithValue(favoritesRepository),
        triviaRepositoryProvider.overrideWithValue(triviaRepository),
        graphQLClientProvider.overrideWithValue(clientNotifier.value),
        pokemonCacheServiceProvider.overrideWithValue(pokemonCacheService),
      ],
      child: MyApp(clientNotifier: clientNotifier),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({
    super.key,
    required this.clientNotifier,
  });

  final ValueNotifier<GraphQLClient> clientNotifier;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void dispose() {
    widget.clientNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(currentLocaleProvider);
    
    return GraphQLProvider(
      client: widget.clientNotifier,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pokédex GraphQL',
        themeMode: themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthGate(),
      ),
    );
  }
}
