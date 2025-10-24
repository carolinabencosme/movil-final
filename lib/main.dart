import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_config.dart';
import 'controllers/auth_controller.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'services/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  final clientNotifier = initGraphQLClient();
  final themeController = ThemeController();
  final authRepository = await AuthRepository.init();
  final authController = AuthController(repository: authRepository);

  runApp(
    MyApp(
      clientNotifier: clientNotifier,
      themeController: themeController,
      authController: authController,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.clientNotifier,
    required this.themeController,
    required this.authController,
  });

  final ValueNotifier<GraphQLClient> clientNotifier;
  final ThemeController themeController;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      notifier: themeController,
      child: AuthScope(
        notifier: authController,
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
                home: AuthGate(controller: authController),
              ),
            );
          },
        ),
      ),
    );
  }
}
