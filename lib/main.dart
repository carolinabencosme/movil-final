import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_config.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  final clientNotifier = initGraphQLClient();

  runApp(MyApp(clientNotifier: clientNotifier));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.clientNotifier});

  final ValueNotifier<GraphQLClient> clientNotifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.redAccent,
      brightness: Brightness.light,
    );

    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    );

    final theme = baseTheme.copyWith(
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: baseTheme.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        selectedColor: colorScheme.primaryContainer,
        secondaryLabelStyle: baseTheme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),
      useMaterial3: true,
    );

    return GraphQLProvider(
      client: clientNotifier,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pokédex GraphQL',
        theme: theme,
        home: const HomeScreen(),
      ),
    );
  }
}
