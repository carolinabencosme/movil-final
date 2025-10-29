# Pokédex GraphQL móvil

Esta aplicación Flutter consume la beta GraphQL de la PokéAPI para ofrecer un catálogo interactivo de criaturas, habilidades y estadísticas, junto con autenticación local y personalización de tema.

## Requisitos previos
- Flutter 3.24.0 o superior (incluye Dart 3.9) y herramientas de línea de comando configuradas.
- Dispositivo o emulador para Android/iOS, o Chrome para ejecutar como aplicación web.
- Acceso a Internet para consumir el endpoint `https://beta.pokeapi.co/graphql/v1beta`.

## Instalación
1. Clona el repositorio y entra en la carpeta del proyecto.
2. Ejecuta `flutter pub get` para restaurar las dependencias.
3. (Opcional) En iOS, abre `ios/` y corre `pod install` tras asegurarte de tener CocoaPods configurado.
4. Si es la primera vez que usas Hive en el dispositivo/emulador, no se requiere configuración adicional: los boxes se crean automáticamente al iniciar la app.

## Comandos comunes
### Ejecutar la aplicación
- `flutter run` para lanzar en el dispositivo/emulador predeterminado.
- `flutter run -d chrome` para probar la versión web.

### Pruebas y calidad
- `flutter test` para ejecutar la suite de pruebas unitarias.
- `flutter analyze` para revisar el cumplimiento de las reglas de linting.

## Arquitectura y organización
- **`lib/controllers/`** contiene lógica de negocio desacoplada de la UI. `auth_controller.dart` orquesta el estado de autenticación y expone el `AuthScope` para que los widgets reaccionen a los cambios. 
- **`lib/models/`** define entidades ricas como `PokemonListItem`, `PokemonDetail`, `AbilitySummary` y `UserModel` para mapear la respuesta GraphQL o persistir datos locales.
- **`lib/queries/`** centraliza los documentos GraphQL reutilizables (`get_pokemon_list.dart`, `get_pokemon_details.dart`, `get_pokemon_abilities.dart`, `get_pokemon_types.dart`).
- **`lib/screens/`** alberga la capa de presentación: flujo de autenticación (`auth/`), listados (`pokedex_screen.dart`, `abilities_screen.dart`), detalle (`detail_screen.dart`, `ability_detail_screen.dart`) y ajustes (`settings_screen.dart`, `profile_settings_screen.dart`).
- **`lib/widgets/`** reúne componentes reutilizables (por ejemplo, tarjetas, ilustraciones y secciones visuales).

## Inicialización de GraphQL y scopes globales
- `lib/graphql_config.dart` crea un `GraphQLClient` con `HttpLink` apuntando a la PokéAPI y un `GraphQLCache` respaldado por `InMemoryStore`, listo para compartir entre widgets.
- En `lib/main.dart`, `initHiveForFlutter()` prepara el almacenamiento local, se inicializan `AuthController` y `ThemeController`, y `MyApp` compone la jerarquía de scopes: `ThemeScope` → `AuthScope` → `GraphQLProvider` → `MaterialApp`.
- `ThemeScope` y `AuthScope` son `InheritedNotifier` que permiten acceso reactivo al tema y a la sesión en todo el árbol de widgets.

## Ejemplos de queries GraphQL
```graphql
# Listado dinámico de Pokémon con filtros y ordenamiento
query GetPokemonList($limit: Int!, $offset: Int!, $search: String!, $typeNames: [String!]) {
  pokemon_v2_pokemon(
    limit: $limit,
    offset: $offset,
    order_by: {name: asc},
    where: {
      _and: [
        { _or: [{name: {_ilike: $search}}] },
        { pokemon_v2_pokemontypes: {pokemon_v2_type: {name: {_in: $typeNames}}}}
      ]
    }
  ) {
    id
    name
    pokemon_v2_pokemonsprites(limit: 1) { sprites }
  }
}
```

```graphql
# Detalle completo de un Pokémon
query GetPokemonDetails($id: Int!, $languageId: Int!) {
  pokemon_v2_pokemon_by_pk(id: $id) {
    id
    name
    height
    weight
    pokemon_v2_pokemontypes { pokemon_v2_type { id name } }
    pokemon_v2_pokemonabilities { pokemon_v2_ability { name } }
    pokemon_v2_pokemonstats { base_stat pokemon_v2_stat { name } }
    pokemon_v2_pokemonmoves { level pokemon_v2_move { name } }
  }
  pokemon_v2_typeefficacy { damage_factor damage_type_id target_type_id }
}
```

```graphql
# Catálogo de habilidades
query GetPokemonAbilities {
  pokemon_v2_ability(order_by: {name: asc}) {
    id
    name
    pokemon_v2_abilitynames(where: {language_id: {_in: [7, 9]}}) { name }
    pokemon_v2_abilityeffecttexts(where: {language_id: {_in: [7, 9]}}) {
      short_effect
      effect
    }
  }
}
```

## Estrategia de caché y manejo de errores
- El `GraphQLClient` usa `GraphQLCache` en memoria, lo que permite reutilizar resultados entre vistas mientras la sesión está activa.
- `PokedexScreen` fuerza `FetchPolicy.networkOnly` para garantizar listados frescos cuando se aplican filtros, con paginación incremental y limpieza del estado en `_handleError` y `_handleGenericError` (reinicia la lista, muestra `SnackBar` y mantiene la bandera `_hasMore`).
- `AbilitiesScreen` y `AbilityDetailScreen` optan por `FetchPolicy.cacheAndNetwork`: muestran datos cacheados al instante y refrescan en segundo plano, mostrando indicadores de carga y estados vacíos o de error cuando es necesario.
- `DetailScreen` utiliza el `Query` de `graphql_flutter` con estado derivado: indicadores de carga, mensajes en caso de `hasException` y `RefreshIndicator` para volver a consultar manualmente.

## Flujo de autenticación
1. `AuthRepository` (Hive) registra usuarios aplicando `sha256` a las contraseñas, persiste sesiones (`auth_session_box`) y expone operaciones `login`, `registerUser`, `updateProfile` y `logout`.
2. `AuthController` coordina el repositorio, expone flags (`isAuthenticated`, `isLoading`, `errorMessage`) y métodos asíncronos que actualizan el estado y notifican a los listeners.
3. `AuthGate` escucha al controlador para redirigir entre `LoginScreen`/`RegisterScreen` y la navegación autenticada (`HomeScreen`).
4. Las pantallas de login y registro validan formularios, muestran `SnackBar` en fallos y delegan en el controlador; `ProfileSettingsScreen` permite cambiar correo y contraseña con validación adicional.

## Ajustes de tema
- `ThemeController` mantiene el `ThemeMode` actual y notifica cambios; se expone mediante `ThemeScope` para acceso global.
- `SettingsScreen` ofrece un selector `RadioListTile` para alternar entre modo claro y oscuro, aplicando los cambios de forma inmediata a través de `ThemeController.updateThemeMode`.
- `AppTheme.light` y `AppTheme.dark` (en `lib/theme/`) definen paletas y estilos coherentes para ambos modos.

## Checklist de funcionalidades
- [x] Registro, inicio de sesión, persistencia de sesión y cierre con almacenamiento local seguro.
- [x] Listado de Pokémon con búsqueda, filtros avanzados, paginación y conteo total.
- [x] Detalle de Pokémon con estadísticas, habilidades, movimientos y cadena evolutiva.
- [x] Catálogo de habilidades con búsqueda, animaciones y vista de detalle.
- [x] Edición de perfil y cambio de contraseña con validaciones y feedback.
- [x] Selector de tema claro/oscuro aplicado globalmente.
- [ ] Secciones de movimientos, máquinas y checklists (solo placeholders visuales en el Home).

## Pruebas
Ejecuta `flutter test` para validar la lógica disponible. Agrega pruebas unitarias/widget nuevas en `test/` para cubrir escenarios adicionales conforme evolucione la aplicación.
