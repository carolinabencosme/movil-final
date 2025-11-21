# Implementación de Riverpod para Gestión de Estado

## Resumen

Este proyecto ahora utiliza **Riverpod** como solución de gestión de estado, reemplazando el patrón anterior de `ChangeNotifier` + `InheritedNotifier` con scopes personalizados.

## ¿Por qué Riverpod?

Riverpod es una solución moderna de gestión de estado para Flutter que ofrece:

- **Tipado fuerte**: Detecta errores en tiempo de compilación
- **Sin dependencia de BuildContext**: Los providers se pueden leer desde cualquier lugar
- **Mejor testabilidad**: Fácil de mockear y testear
- **Hot reload mejorado**: Soporta completamente hot reload
- **Sin problemas de dependencias circulares**: Maneja automáticamente las dependencias entre providers

## Arquitectura

### Providers Creados

Se crearon providers en la carpeta `lib/providers/` para cada controlador:

1. **auth_provider.dart**: Gestión de autenticación
   - `authRepositoryProvider`: Proporciona AuthRepository
   - `authControllerProvider`: Proporciona AuthController
   - `isAuthenticatedProvider`: Estado de autenticación
   - `authLoadingProvider`: Estado de carga
   - `currentUserEmailProvider`: Email del usuario actual

2. **favorites_provider.dart**: Gestión de favoritos
   - `favoritesRepositoryProvider`: Proporciona FavoritesRepository
   - `favoritesControllerProvider`: Proporciona FavoritesController
   - `favoriteIdsProvider`: Lista de IDs favoritos
   - `favoritePokemonsProvider`: Lista de Pokémon favoritos
   - `isFavoriteProvider`: Verifica si un Pokémon es favorito

3. **trivia_provider.dart**: Gestión de trivia
   - `graphQLClientProvider`: Cliente GraphQL
   - `pokemonCacheServiceProvider`: Servicio de caché
   - `triviaRepositoryProvider`: Repositorio de trivia
   - `triviaControllerProvider`: Controlador de trivia
   - `currentPokemonProvider`: Pokémon actual
   - `triviaScoreProvider`: Puntuación actual
   - `triviaStreakProvider`: Racha actual

4. **theme_provider.dart**: Gestión de tema
   - `themeControllerProvider`: Controlador de tema
   - `themeModeProvider`: Modo de tema actual
   - `isDarkModeProvider`: Indica si está en modo oscuro

5. **locale_provider.dart**: Gestión de idioma
   - `localeControllerProvider`: Controlador de idioma
   - `currentLocaleProvider`: Idioma actual

### Cambios en main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  
  // Inicialización de servicios
  final clientNotifier = await initGraphQLClient();
  final pokemonCacheService = await PokemonCacheService.init();
  final authRepository = await AuthRepository.init();
  final favoritesRepository = await FavoritesRepository.init(pokemonCacheService);
  final triviaRepository = await TriviaRepository.init();

  // ProviderScope con overrides de servicios
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
```

### Actualización de Screens

Todas las pantallas se convirtieron de `StatefulWidget`/`StatelessWidget` a `ConsumerStatefulWidget`/`ConsumerWidget`:

**Antes:**
```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.controller, ...});
  final AuthController controller;
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller.isLoading;
    // ...
  }
}
```

**Después:**
```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({...}); // Sin controller parameter
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authLoadingProvider);
    // Para acciones: ref.read(authControllerProvider).login(...)
  }
}
```

### Uso de Providers

#### Leer estado que causa rebuilds (usar en build)
```dart
final isLoading = ref.watch(authLoadingProvider);
final favorites = ref.watch(favoritePokemonsProvider);
final themeMode = ref.watch(themeModeProvider);
```

#### Leer estado sin causar rebuilds (usar en callbacks)
```dart
final controller = ref.read(authControllerProvider);
await controller.login(email: email, password: password);
```

#### Escuchar cambios manualmente
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final controller = ref.read(triviaControllerProvider);
  controller.addListener(_onControllerChanged);
}
```

## Ventajas de la Implementación

1. **Código más limpio**: No es necesario pasar controllers como parámetros
2. **Mejor separación**: Los providers están centralizados
3. **Más testeable**: Fácil overriding de providers en tests
4. **Type-safe**: Errores detectados en compilación
5. **Menos boilerplate**: No necesidad de InheritedWidgets personalizados

## Testing

Se creó `test/riverpod_integration_test.dart` que demuestra cómo testear con Riverpod:

```dart
test('authControllerProvider provides AuthController', () {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );
  
  final controller = container.read(authControllerProvider);
  expect(controller, isA<AuthController>());
  
  container.dispose();
});
```

## Migración Completa

✅ Todos los controllers mantienen su lógica original
✅ Todos los screens actualizados para usar Riverpod
✅ Scopes personalizados reemplazados por Riverpod
✅ Tests básicos de integración agregados
✅ Documentación actualizada

## Próximos Pasos (Opcional)

- Convertir controllers a StateNotifiers para mejor integración con Riverpod
- Agregar más providers granulares para optimización
- Implementar providers con familias para datos parametrizados
- Agregar tests unitarios más exhaustivos
