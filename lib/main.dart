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
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFE94256),
      onPrimary: Colors.white,
      secondary: Color(0xFFF2A649),
      onSecondary: Color(0xFF111118),
      tertiary: Color(0xFF4DA3FF),
      onTertiary: Color(0xFF021326),
      background: Color(0xFF0B0B0F),
      onBackground: Colors.white,
      surface: Color(0xFF16161D),
      onSurface: Color(0xFFE6E6F0),
      surfaceVariant: Color(0xFF1F1F28),
      onSurfaceVariant: Color(0xFFCACAD6),
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
      outline: Color(0xFF30303A),
    );

    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    final textTheme = baseTheme.textTheme
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        )
        .copyWith(
          headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: colorScheme.outline.withOpacity(0.3),
      ),
    );

    final theme = baseTheme.copyWith(
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: baseTheme.iconTheme.copyWith(
          color: colorScheme.onBackground,
        ),
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.35),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: colorScheme.surfaceVariant,
        disabledColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        iconTheme: baseTheme.iconTheme.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        showCheckmark: false,
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: inputBorder,
        enabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
      textTheme: textTheme,
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
