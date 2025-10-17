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
    return GraphQLProvider(
      client: clientNotifier,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pokédex GraphQL',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
