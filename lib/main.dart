import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_config.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  final clientNotifier = initGraphQLClient();
  final themeController = ThemeController();

  runApp(
    MyApp(
      clientNotifier: clientNotifier,
      themeController: themeController,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.clientNotifier,
    required this.themeController,
  });

  final ValueNotifier<GraphQLClient> clientNotifier;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      notifier: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return GraphQLProvider(
            client: clientNotifier,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Pokédex GraphQL',
              themeMode: themeController.themeMode,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              home: const HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
