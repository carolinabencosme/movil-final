# Documentación Completa - Pokédex GraphQL App

## 📱 Introducción

Esta es una aplicación móvil desarrollada en **Flutter** que funciona como una Pokédex completa e interactiva. La aplicación consume datos de la **PokéAPI GraphQL** (versión beta) para proporcionar información detallada sobre Pokémon, sus habilidades, tipos, estadísticas, movimientos y cadenas evolutivas.

### ¿Qué hace esta aplicación?

La aplicación permite a los usuarios:
- 🔐 **Autenticarse** con un sistema de login y registro local
- 📚 **Explorar** un catálogo completo de Pokémon con búsqueda y filtros
- 🔍 **Ver detalles** completos de cada Pokémon (stats, tipos, habilidades, movimientos, evoluciones)
- ✨ **Consultar habilidades** con descripciones y efectos
- ⚙️ **Personalizar** el tema de la app (modo claro u oscuro)
- 👤 **Gestionar perfil** (cambiar email y contraseña)
- 💾 **Persistir sesión** para mantener al usuario logueado entre reinicios

---

## 🏗️ Arquitectura General

La aplicación sigue una **arquitectura en capas** limpia y organizada:

```
┌─────────────────────────────────────────┐
│          Capa de Presentación           │
│     (Screens, Widgets, UI Logic)        │
├─────────────────────────────────────────┤
│        Capa de Controladores            │
│  (AuthController, ThemeController)      │
├─────────────────────────────────────────┤
│         Capa de Servicios               │
│   (AuthRepository, GraphQL Client)      │
├─────────────────────────────────────────┤
│          Capa de Datos                  │
│    (Models, Queries, Local Storage)     │
└─────────────────────────────────────────┘
```

### Principios de diseño:
- **Separación de responsabilidades**: La UI está separada de la lógica de negocio
- **Reutilización**: Componentes y widgets reutilizables
- **Reactividad**: Uso de `ChangeNotifier` y `InheritedNotifier` para gestión de estado
- **Escalabilidad**: Estructura modular que facilita añadir nuevas funcionalidades

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
├── graphql_config.dart            # Configuración del cliente GraphQL
│
├── controllers/                   # Controladores de lógica de negocio
│   └── auth_controller.dart       # Gestión de autenticación
│
├── services/                      # Servicios y repositorios
│   └── auth_repository.dart       # Persistencia y lógica de auth
│
├── models/                        # Modelos de datos
│   ├── pokemon_model.dart         # Modelos de Pokémon
│   ├── ability_model.dart         # Modelos de habilidades
│   └── user_model.dart            # Modelo de usuario
│
├── queries/                       # Queries GraphQL
│   ├── get_pokemon_list.dart      # Query para listar Pokémon
│   ├── get_pokemon_details.dart   # Query para detalles de Pokémon
│   ├── get_pokemon_abilities.dart # Query para habilidades
│   └── get_pokemon_types.dart     # Query para tipos
│
├── screens/                       # Pantallas de la aplicación
│   ├── auth/                      # Pantallas de autenticación
│   │   ├── auth_gate.dart         # Guarda de autenticación
│   │   ├── login_screen.dart      # Pantalla de login
│   │   └── register_screen.dart   # Pantalla de registro
│   ├── home_screen.dart           # Pantalla principal con menú
│   ├── pokedex_screen.dart        # Lista de Pokémon
│   ├── detail_screen.dart         # Detalles de un Pokémon
│   ├── abilities_screen.dart      # Lista de habilidades
│   ├── ability_detail_screen.dart # Detalles de una habilidad
│   ├── settings_screen.dart       # Configuración de tema
│   └── profile_settings_screen.dart # Edición de perfil
│
├── widgets/                       # Widgets reutilizables
│   ├── pokemon_artwork.dart       # Widget para mostrar imagen de Pokémon
│   └── detail/                    # Widgets específicos de detalles
│       ├── tabs/                  # Pestañas de detalle
│       ├── stats/                 # Componentes de estadísticas
│       ├── evolution/             # Componentes de evolución
│       ├── moves/                 # Componentes de movimientos
│       ├── matchups/              # Componentes de efectividad de tipos
│       └── animations/            # Animaciones y efectos visuales
│
└── theme/                         # Configuración de temas
    ├── app_theme.dart             # Definición de temas claro y oscuro
    ├── theme_controller.dart      # Controlador de tema
    └── pokemon_type_colors.dart   # Colores por tipo de Pokémon
```

---

## 🔐 Sistema de Autenticación

### Componentes principales:

#### 1. **AuthRepository** (`services/auth_repository.dart`)
Es el repositorio que maneja toda la persistencia y lógica de autenticación:

**Funcionalidades:**
- **Registro de usuarios**: Almacena email y contraseña hasheada (SHA-256)
- **Login**: Valida credenciales comparando hashes
- **Gestión de sesión**: Persiste el usuario actual en Hive
- **Actualización de perfil**: Permite cambiar email y contraseña
- **Logout**: Elimina la sesión actual
- **Restauración de sesión**: Recupera el usuario al iniciar la app

**Almacenamiento:**
```dart
// Caja para usuarios registrados
final usersBox = await Hive.openBox<UserModel>('auth_users_box');

// Caja para sesión activa
final sessionBox = await Hive.openBox<String>('auth_session_box');
```

**Seguridad:**
- Las contraseñas nunca se almacenan en texto plano
- Se usa SHA-256 para hashear contraseñas
- Los emails se normalizan (lowercase, trim) para evitar duplicados

#### 2. **AuthController** (`controllers/auth_controller.dart`)
Controlador que coordina la UI con el repositorio:

**Responsabilidades:**
- Exponer métodos asíncronos para login, registro y logout
- Gestionar estados de carga (`isLoading`)
- Notificar errores a la UI (`errorMessage`)
- Proporcionar estado de autenticación (`isAuthenticated`)

**Patrón usado:** `ChangeNotifier` + `InheritedNotifier`

```dart
// Acceso desde cualquier widget:
final authController = AuthScope.of(context);
if (authController.isAuthenticated) {
  // Usuario está logueado
}
```

#### 3. **AuthGate** (`screens/auth/auth_gate.dart`)
Widget que actúa como "guardia" de autenticación:

```dart
// Si no está autenticado → LoginScreen
// Si está autenticado → HomeScreen
```

### Flujo de autenticación:

```
┌─────────────┐
│  App inicia │
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ AuthRepository   │
│ restaura sesión  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐    NO     ┌──────────────┐
│ ¿Usuario existe? │ ────────> │ LoginScreen  │
└──────┬───────────┘            └──────────────┘
       │ SÍ
       ▼
┌──────────────────┐
│   HomeScreen     │
└──────────────────┘
```

---

## 🔌 Configuración de GraphQL

### Cliente GraphQL (`graphql_config.dart`)

La aplicación se conecta a la **PokéAPI GraphQL beta**:

```dart
const API_URL = 'https://beta.pokeapi.co/graphql/v1beta'
```

**Configuración del cliente:**
```dart
ValueNotifier<GraphQLClient> initGraphQLClient() {
  // 1. Link HTTP para conectar con la API
  final HttpLink httpLink = HttpLink(API_URL);
  
  // 2. Store en memoria para caché
  final InMemoryStore store = InMemoryStore();
  
  // 3. Políticas de caché optimizadas
  final Policies defaultQueryPolicies = Policies(
    fetch: FetchPolicy.cacheFirst,    // Usa caché primero
    error: ErrorPolicy.all,            // Captura todos los errores
    cacheReread: CacheRereadPolicy.mergeOptimistic,
  );
  
  return ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: store),
      defaultPolicies: DefaultPolicies(
        watchQuery: defaultQueryPolicies,
        query: defaultQueryPolicies,
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    ),
  );
}
```

### Estrategias de caché:

1. **PokedexScreen**: `FetchPolicy.networkOnly`
   - Siempre consulta la red para tener datos frescos
   - Importante para búsquedas y filtros dinámicos

2. **AbilitiesScreen**: `FetchPolicy.cacheAndNetwork`
   - Muestra datos cacheados inmediatamente
   - Actualiza en segundo plano

3. **DetailScreen**: `FetchPolicy.cacheFirst`
   - Usa caché si está disponible
   - Reduce latencia y uso de red

### Ventajas del caché:
- ⚡ Respuesta instantánea al regresar a pantallas visitadas
- 📶 Reduce uso de datos móviles
- 🔄 Mejora experiencia de usuario

---

## 🎨 Sistema de Temas

### ThemeController (`theme/theme_controller.dart`)

Controlador simple que gestiona el modo de tema:

```dart
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  void updateThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Actualiza toda la app
  }
}
```

### Temas definidos (`theme/app_theme.dart`)

**Tema Claro:**
- Fondo blanco/gris claro
- Texto oscuro
- Colores vibrantes para Pokémon

**Tema Oscuro:**
- Fondo negro/gris oscuro
- Texto claro
- Colores ajustados para buena legibilidad

**Acceso global:**
```dart
// Desde cualquier widget:
final themeController = ThemeScope.of(context);
themeController.updateThemeMode(ThemeMode.dark);
```

### Colores por tipo de Pokémon

El archivo `pokemon_type_colors.dart` define colores específicos para cada tipo:

```dart
final typeColors = {
  'fire': Color(0xFFE94256),
  'water': Color(0xFF4DA3FF),
  'grass': Color(0xFF59CD90),
  'electric': Color(0xFFF2A649),
  // ... etc
};
```

Estos colores se usan en:
- Tarjetas de Pokémon
- Badges de tipos
- Fondos de pantallas de detalle
- Indicadores de efectividad

---

## 📺 Pantallas Principales

### 1. **HomeScreen** (`screens/home_screen.dart`)

Pantalla principal con un **menú de secciones en grid**:

**Secciones disponibles:**
- 🔴 **Pokédex**: Catálogo completo de Pokémon (implementado)
- ⚡ **Moves**: Movimientos y ataques (placeholder)
- 💾 **TM**: Máquinas técnicas (placeholder)
- ✨ **Abilities**: Habilidades (implementado)
- ✅ **Checklists**: Listas de seguimiento (placeholder)
- 👥 **Parties**: Equipos y estrategias (placeholder)
- 🗺️ **Locations**: Regiones y mapas (placeholder)

**Características de diseño:**
- Animaciones de entrada suaves
- Hero transitions entre secciones
- Cards coloridas con gradientes
- Iconos y gráficos decorativos
- Botón de configuración en header

**Navegación:**
```dart
Navigator.push(
  PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 450),
    pageBuilder: (_, animation, __) => FadeTransition(
      opacity: animation,
      child: PokedexScreen(),
    ),
  ),
);
```

### 2. **PokedexScreen** (`screens/pokedex_screen.dart`)

Lista completa de Pokémon con funcionalidades avanzadas:

**Funcionalidades:**
- 🔍 **Búsqueda por nombre**: Input en tiempo real
- 🏷️ **Filtros por tipo**: Checkboxes múltiples (fire, water, grass, etc.)
- 📊 **Ordenamiento**: Alfabético ascendente
- ♾️ **Paginación infinita**: Carga automática al hacer scroll
- 📱 **Grid adaptativo**: 2 columnas en portrait, responsivo

**Estructura de datos:**
```dart
List<PokemonListItem> pokemonList = [];
int currentOffset = 0;
const int limit = 20; // Pokémon por página
```

**Query GraphQL usado:**
```graphql
query GetPokemonList(
  $limit: Int!
  $offset: Int!
  $search: String!
  $typeNames: [String!]
) {
  pokemon_v2_pokemon(
    limit: $limit
    offset: $offset
    order_by: {name: asc}
    where: {
      _and: [
        { _or: [{name: {_ilike: $search}}] }
        { pokemon_v2_pokemontypes: {
            pokemon_v2_type: {name: {_in: $typeNames}}
        }}
      ]
    }
  ) {
    id
    name
    pokemon_v2_pokemonsprites { sprites }
    pokemon_v2_pokemontypes {
      pokemon_v2_type { name }
    }
  }
}
```

**Tarjetas de Pokémon:**
Cada tarjeta muestra:
- Imagen oficial del Pokémon
- Número de Pokédex (#001, #025, etc.)
- Nombre capitalizado
- Badges de tipos con colores
- Efecto hover/tap

### 3. **DetailScreen** (`screens/detail_screen.dart`)

Pantalla de **detalles completos** de un Pokémon:

**Secciones con tabs:**

#### Tab 1: About (Información general)
- **Características físicas:**
  - Altura en metros
  - Peso en kilogramos
  - Categoría (ej: "Seed Pokémon")
  - Experiencia base
  - Tasa de captura

#### Tab 2: Stats (Estadísticas)
- **6 estadísticas base:**
  - HP (Hit Points)
  - Attack
  - Defense
  - Special Attack
  - Special Defense
  - Speed
- Barras de progreso visuales
- Colores según el valor (verde alto, rojo bajo)

#### Tab 3: Evolution (Evolución)
- **Cadena evolutiva completa**
- Gráfico visual de evoluciones
- Condiciones de evolución (nivel, piedra, intercambio)
- Imágenes de cada forma evolutiva
- Resaltado del Pokémon actual

#### Tab 4: Moves (Movimientos)
- **Lista completa de movimientos**
- Filtros por método:
  - Level-up
  - Machine (TM/HM)
  - Egg
  - Tutor
- Nivel de aprendizaje
- Tipo del movimiento

#### Tab 5: Matchups (Efectividad)
- **Tabla de efectividad de tipos**
- Multiplicadores de daño:
  - 4x (súper efectivo)
  - 2x (efectivo)
  - 0.5x (poco efectivo)
  - 0.25x (muy poco efectivo)
  - 0x (inmune)
- Colores según efectividad

**Header animado:**
- Artwork grande del Pokémon
- Fondo con gradiente del tipo principal
- Partículas flotantes animadas
- Transición Hero desde la lista

### 4. **AbilitiesScreen** (`screens/abilities_screen.dart`)

Catálogo de **todas las habilidades** de Pokémon:

**Funcionalidades:**
- 🔍 Búsqueda por nombre
- 📜 Lista alfabética completa
- 💫 Animaciones de entrada escalonadas
- 🎨 Cards con efectos visuales

**Información mostrada:**
- Nombre de la habilidad (localizado)
- Descripción corta del efecto
- Icono decorativo

**Query GraphQL:**
```graphql
query GetPokemonAbilities {
  pokemon_v2_ability(order_by: {name: asc}) {
    id
    name
    pokemon_v2_abilitynames(where: {language_id: {_in: [7, 9]}}) {
      name
    }
    pokemon_v2_abilityeffecttexts(where: {language_id: {_in: [7, 9]}}) {
      short_effect
      effect
    }
  }
}
```

### 5. **AbilityDetailScreen** (`screens/ability_detail_screen.dart`)

Detalles completos de una habilidad:

**Muestra:**
- Nombre completo
- Descripción detallada del efecto
- Pokémon que pueden tener esta habilidad
- Grid de Pokémon con links

### 6. **SettingsScreen** (`screens/settings_screen.dart`)

Configuración de la aplicación:

**Opciones:**
- 🌓 **Tema**: Light / Dark mode
  - RadioListTile para selección
  - Cambio inmediato al seleccionar
- �� **Perfil**: Link a ProfileSettingsScreen
- 🚪 **Logout**: Cerrar sesión

### 7. **ProfileSettingsScreen** (`screens/profile_settings_screen.dart`)

Edición de perfil de usuario:

**Campos editables:**
- 📧 Email actual (mostrado)
- 📧 Nuevo email (opcional)
- 🔐 Nueva contraseña (opcional)
- ✅ Confirmación de nueva contraseña

**Validaciones:**
- Email válido (formato)
- Contraseña mínimo 6 caracteres
- Confirmación debe coincidir
- Al menos un campo nuevo debe estar lleno

**Feedback:**
- SnackBar de éxito
- SnackBar de error con mensaje específico
- Loading indicator durante actualización

---

## 📦 Modelos de Datos

### 1. **PokemonListItem** (`models/pokemon_model.dart`)

Modelo **ligero** para la lista de Pokémon:

```dart
class PokemonListItem {
  final int id;              // ID de Pokédex
  final String name;         // Nombre
  final String imageUrl;     // URL de imagen
  final List<String> types;  // Tipos ["fire", "flying"]
  final List<PokemonStat> stats; // Estadísticas base
}
```

**Propósito:** Optimizar rendimiento en listas largas

### 2. **PokemonDetail** (`models/pokemon_model.dart`)

Modelo **completo** para detalles:

```dart
class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<PokemonAbilityDetail> abilities;
  final List<PokemonStat> stats;
  final PokemonCharacteristics characteristics;
  final List<TypeMatchup> typeMatchups;
  final List<PokemonMove> moves;
  final PokemonEvolutionChain? evolutionChain;
}
```

**Incluye:**
- Todos los datos de `PokemonListItem`
- Habilidades con descripción
- Características físicas
- Movimientos aprendibles
- Cadena evolutiva
- Efectividad de tipos

### 3. **PokemonAbilityDetail**

```dart
class PokemonAbilityDetail {
  final String name;
  final String description;
  final bool isHidden; // Si es habilidad oculta
}
```

### 4. **PokemonStat**

```dart
class PokemonStat {
  final String name;     // "hp", "attack", "defense"...
  final int baseStat;    // Valor base (1-255)
}
```

### 5. **PokemonMove**

```dart
class PokemonMove {
  final int? id;
  final String name;
  final String method;       // "level-up", "machine", "egg"
  final String? type;        // Tipo del movimiento
  final int? level;          // Nivel de aprendizaje
  final String? versionGroup; // Versión del juego
}
```

### 6. **PokemonEvolutionChain**

```dart
class PokemonEvolutionChain {
  final List<List<PokemonEvolutionNode>> groups;
  final List<List<PokemonEvolutionNode>> paths;
  final int? currentSpeciesId;
}
```

**Estructura:**
- `groups`: Evoluciones agrupadas por nivel
- `paths`: Caminos evolutivos completos
- `currentSpeciesId`: Para resaltar Pokémon actual

### 7. **TypeMatchup**

```dart
class TypeMatchup {
  final String type;        // Tipo atacante
  final double multiplier;  // Multiplicador (0, 0.25, 0.5, 1, 2, 4)
}
```

### 8. **UserModel** (`models/user_model.dart`)

```dart
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String email;
  
  @HiveField(1)
  final String passwordHash; // SHA-256
}
```

**Adaptador Hive:** Generado automáticamente para serialización

### 9. **AbilitySummary** (`models/ability_model.dart`)

```dart
class AbilitySummary {
  final int id;
  final String name;
  final String displayName;     // Nombre localizado
  final String shortEffect;     // Descripción corta
  final String? fullEffect;     // Descripción completa
}
```

---

## 🔍 Queries GraphQL

Todas las queries están centralizadas en `lib/queries/` para reutilización:

### 1. **get_pokemon_list.dart**

Obtiene lista de Pokémon con paginación y filtros:

**Variables:**
- `$limit`: Int! - Cantidad por página
- `$offset`: Int! - Desplazamiento
- `$search`: String! - Búsqueda por nombre
- `$typeNames`: [String!] - Filtro por tipos

**Retorna:**
- ID, nombre, sprites, tipos

### 2. **get_pokemon_details.dart**

Obtiene todos los detalles de un Pokémon:

**Variables:**
- `$id`: Int! - ID del Pokémon
- `$languageId`: Int! - Idioma (9 = inglés)

**Retorna:**
- Información completa
- Especies y evoluciones
- Movimientos y habilidades
- Tipos y efectividades

### 3. **get_pokemon_abilities.dart**

Lista todas las habilidades:

**Retorna:**
- ID, nombre
- Nombres localizados
- Efectos (corto y completo)

### 4. **get_pokemon_types.dart**

Obtiene información de tipos:

**Retorna:**
- Tipos disponibles
- Relaciones de efectividad

---

## 🧩 Widgets Reutilizables

### 1. **PokemonArtwork** (`widgets/pokemon_artwork.dart`)

Widget para mostrar imagen de Pokémon:

**Características:**
- Carga asíncrona de imagen
- Placeholder mientras carga
- Error handling
- Caché de imágenes
- Hero animation ready

**Uso:**
```dart
PokemonArtwork(
  imageUrl: pokemon.imageUrl,
  size: 200,
  heroTag: 'pokemon-${pokemon.id}',
)
```

### 2. **DetailTabs** (`widgets/detail/tabs/detail_tabs.dart`)

Sistema de tabs para DetailScreen:

**Tabs:**
- About
- Stats
- Evolution
- Moves
- Matchups

**Navegación:**
- TabBar con indicador animado
- TabBarView con scroll physics
- Estado persistente entre tabs

### 3. **StatComponents** (`widgets/detail/stats/stat_components.dart`)

Componentes para mostrar estadísticas:

**Widgets:**
- `StatBar`: Barra de progreso animada
- `StatRow`: Fila con nombre y valor
- `StatsGrid`: Grid de todas las stats

**Colores:**
- Verde: Stats altas (>100)
- Amarillo: Stats medias (50-100)
- Rojo: Stats bajas (<50)

### 4. **EvolutionComponents** (`widgets/detail/evolution/evolution_components.dart`)

Componentes para cadena evolutiva:

**Widgets:**
- `EvolutionCard`: Card de una evolución
- `EvolutionArrow`: Flecha con condición
- `EvolutionChain`: Cadena completa

**Layout:**
- Horizontal scroll
- Flechas entre evoluciones
- Highlight en Pokémon actual

### 5. **MovesComponents** (`widgets/detail/moves/moves_components.dart`)

Componentes para movimientos:

**Widgets:**
- `MoveCard`: Card de movimiento individual
- `MovesList`: Lista filtrable
- `MethodChip`: Chip de método

**Información:**
- Nombre del movimiento
- Tipo (con color)
- Nivel de aprendizaje
- Método de obtención

### 6. **MatchupComponents** (`widgets/detail/matchups/matchup_components.dart`)

Componentes para efectividad de tipos:

**Widgets:**
- `TypeMatchupRow`: Fila con tipo y multiplicador
- `MatchupsGrid`: Grid de efectividades

**Categorías:**
- Super Effective (4x, 2x)
- Normal (1x) - no se muestra
- Not Very Effective (0.5x, 0.25x)
- No Effect (0x)

### 7. **ParticleField** (`widgets/detail/animations/particle_field.dart`)

Animación de partículas flotantes:

**Uso:**
```dart
ParticleField(
  color: Colors.white,
  particleCount: 50,
  child: YourWidget(),
)
```

**Efecto:**
- Partículas que flotan suavemente
- Movimiento aleatorio
- Fade in/out
- Optimizado con CustomPainter

---

## 🗺️ Flujo de Navegación

```
App Start
   │
   ▼
main.dart
   ├─> Inicializa Hive
   ├─> Crea GraphQLClient
   ├─> Crea AuthController
   ├─> Crea ThemeController
   │
   ▼
MyApp (MaterialApp)
   └─> ThemeScope
       └─> AuthScope
           └─> GraphQLProvider
               │
               ▼
           AuthGate
               │
               ├─> No auth ─> LoginScreen
               │               └─> RegisterScreen
               │
               └─> Auth ──────> HomeScreen
                                   │
                                   ├─> Pokédex ──> PokedexScreen
                                   │                   └─> DetailScreen
                                   │
                                   ├─> Abilities ─> AbilitiesScreen
                                   │                   └─> AbilityDetailScreen
                                   │
                                   ├─> Settings ──> SettingsScreen
                                   │                   └─> ProfileSettingsScreen
                                   │
                                   └─> [Otras secciones - placeholders]
```

### Tipos de navegación usados:

1. **push/pop estándar:**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => DetailScreen(pokemonId: id),
));
```

2. **PageRouteBuilder con animaciones:**
```dart
Navigator.push(context, PageRouteBuilder(
  transitionDuration: Duration(milliseconds: 450),
  pageBuilder: (_, animation, __) => FadeTransition(
    opacity: animation,
    child: PokedexScreen(),
  ),
));
```

3. **Hero transitions:**
```dart
Hero(
  tag: 'pokemon-${pokemon.id}',
  child: PokemonImage(),
)
```

---

## 💾 Almacenamiento Local con Hive

### ¿Qué es Hive?

Hive es una **base de datos NoSQL** rápida y ligera para Flutter:
- 🚀 Muy rápida (escrita en Dart puro)
- 📦 Sin dependencias nativas
- 🔒 Cifrado opcional
- 🧩 Type-safe con adaptadores

### Uso en la app:

#### 1. Inicialización (`main.dart`)

```dart
await initHiveForFlutter(); // Inicializa Hive
```

Esta función (de `graphql_flutter`):
- Inicializa Hive
- Configura directorio de datos
- Registra adaptadores necesarios

#### 2. Cajas (Boxes) usadas:

**Caja de usuarios:**
```dart
final usersBox = await Hive.openBox<UserModel>('auth_users_box');
```
- Almacena todos los usuarios registrados
- Key: email normalizado
- Value: UserModel con hash de contraseña

**Caja de sesión:**
```dart
final sessionBox = await Hive.openBox<String>('auth_session_box');
```
- Almacena email del usuario actual
- Key: 'current_user_email'
- Value: email del usuario logueado

#### 3. Adaptador personalizado:

```dart
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String email;
  
  @HiveField(1)
  final String passwordHash;
}
```

**Registro del adaptador:**
```dart
if (!Hive.isAdapterRegistered(1)) {
  Hive.registerAdapter(UserModelAdapter());
}
```

### Operaciones CRUD:

**Create (Registro):**
```dart
await usersBox.put(email, UserModel(
  email: email,
  passwordHash: hashedPassword,
));
```

**Read (Login):**
```dart
final user = usersBox.get(email);
```

**Update (Cambiar perfil):**
```dart
await usersBox.put(newEmail, updatedUser);
if (newEmail != oldEmail) {
  await usersBox.delete(oldEmail);
}
```

**Delete (Logout):**
```dart
await sessionBox.delete('current_user_email');
```

### Ventajas para esta app:

- ✅ Persistencia de sesión entre reinicios
- ✅ No requiere backend para autenticación
- ✅ Rápido (acceso sincrónico)
- ✅ Seguro (contraseñas hasheadas)
- ✅ Portable (funciona en todos los dispositivos)

---

## 📚 Dependencias del Proyecto

### Dependencias principales:

#### 1. **graphql_flutter: ^5.2.1**
**Propósito:** Cliente GraphQL para Flutter

**Proporciona:**
- `GraphQLClient`: Cliente HTTP para queries
- `GraphQLProvider`: Provider para compartir cliente
- `Query` widget: Widget para ejecutar queries
- `Mutation` widget: Widget para mutaciones
- Cache en memoria

**Uso en la app:**
- Conexión con PokéAPI GraphQL
- Caché de datos de Pokémon
- Gestión de estado de queries

#### 2. **hive: ^2.2.3** y **hive_flutter: ^1.1.0**
**Propósito:** Base de datos NoSQL local

**Proporciona:**
- Almacenamiento key-value
- Adaptadores type-safe
- Operaciones sincrónicas
- Cifrado de datos

**Uso en la app:**
- Almacenamiento de usuarios
- Persistencia de sesión
- Caché de GraphQL

#### 3. **crypto: ^3.0.3**
**Propósito:** Operaciones criptográficas

**Proporciona:**
- Algoritmos de hash (SHA-256, MD5, etc.)
- Codificación base64
- HMAC

**Uso en la app:**
- Hash de contraseñas con SHA-256
- Seguridad en autenticación

#### 4. **flutter_svg: ^2.0.10+1**
**Propósito:** Renderizado de imágenes SVG

**Proporciona:**
- Widget `SvgPicture`
- Cache de SVG
- Colores dinámicos

**Uso en la app:**
- Iconos personalizados
- Gráficos vectoriales
- Assets escalables

#### 5. **flutter_staggered_grid_view: ^0.7.0**
**Propósito:** Grids avanzados y personalizados

**Proporciona:**
- Grids con tamaños variables
- Layouts masonry
- Animaciones de grid

**Uso en la app:**
- Grid de Pokémon en PokedexScreen
- Layouts responsivos
- Animaciones de entrada

#### 6. **cupertino_icons: ^1.0.8**
**Propósito:** Iconos de estilo iOS

**Proporciona:**
- CupertinoIcons
- Consistencia cross-platform

**Uso en la app:**
- Iconos de navegación
- Botones de acción
- UI elements

### Dependencias de desarrollo:

#### 1. **flutter_test**
- Framework de testing de Flutter
- Widgets test
- Unit tests

#### 2. **test: ^1.25.0**
- Testing adicional
- Matchers
- Mocks

#### 3. **flutter_lints: ^5.0.0**
- Reglas de linting
- Mejores prácticas
- Análisis estático

---

## 🔧 Configuración y Setup

### Requisitos:
- Flutter 3.24.0 o superior
- Dart 3.9 o superior
- Android Studio / VS Code
- Emulador o dispositivo físico

### Instalación:

1. **Clonar repositorio:**
```bash
git clone <repo-url>
cd movil-final
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **(iOS) Instalar pods:**
```bash
cd ios
pod install
cd ..
```

4. **Ejecutar app:**
```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome
```

### Comandos útiles:

**Análisis de código:**
```bash
flutter analyze
```

**Tests:**
```bash
flutter test
```

**Build para producción:**
```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

---

## 🎯 Cómo Extender la Aplicación

### Añadir una nueva pantalla:

1. **Crear archivo en `lib/screens/`:**
```dart
// lib/screens/my_new_screen.dart
import 'package:flutter/material.dart';

class MyNewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Pantalla')),
      body: Center(child: Text('Contenido')),
    );
  }
}
```

2. **Añadir navegación:**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => MyNewScreen(),
));
```

### Añadir una nueva query GraphQL:

1. **Crear archivo en `lib/queries/`:**
```dart
// lib/queries/get_my_data.dart
const String GET_MY_DATA = r'''
  query GetMyData($id: Int!) {
    my_table(where: {id: {_eq: $id}}) {
      id
      name
      value
    }
  }
''';
```

2. **Usar en widget:**
```dart
Query(
  options: QueryOptions(
    document: gql(GET_MY_DATA),
    variables: {'id': myId},
  ),
  builder: (result, {refetch, fetchMore}) {
    if (result.isLoading) return CircularProgressIndicator();
    if (result.hasException) return Text('Error');
    
    final data = result.data!['my_table'];
    return MyWidget(data: data);
  },
)
```

### Añadir un nuevo modelo:

1. **Crear clase en `lib/models/`:**
```dart
// lib/models/my_model.dart
class MyModel {
  final int id;
  final String name;
  
  MyModel({required this.id, required this.name});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
```

### Añadir persistencia con Hive:

1. **Definir modelo con anotaciones:**
```dart
import 'package:hive/hive.dart';

part 'my_model.g.dart'; // Generado automáticamente

@HiveType(typeId: 2) // Usar ID único
class MyModel extends HiveObject {
  @HiveField(0)
  final String field1;
  
  @HiveField(1)
  final int field2;
}
```

2. **Generar adaptador:**
```bash
flutter packages pub run build_runner build
```

3. **Registrar y usar:**
```dart
// Registrar
Hive.registerAdapter(MyModelAdapter());

// Abrir box
final box = await Hive.openBox<MyModel>('my_box');

// Usar
await box.put('key', MyModel());
final item = box.get('key');
```

### Añadir un widget reutilizable:

1. **Crear en `lib/widgets/`:**
```dart
// lib/widgets/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  
  const MyWidget({
    required this.title,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
```

2. **Usar en pantallas:**
```dart
MyWidget(
  title: 'Mi Título',
  onTap: () => print('Tap!'),
)
```

---

## 🐛 Debugging y Troubleshooting

### Problemas comunes:

#### 1. **Error: "Hive box not found"**
**Solución:** Asegurarse de inicializar Hive:
```dart
await initHiveForFlutter();
```

#### 2. **Error: "GraphQL query failed"**
**Causas posibles:**
- Sin internet
- API caída
- Query mal formado

**Solución:**
```dart
if (result.hasException) {
  print(result.exception.toString());
}
```

#### 3. **Error: "Image not loading"**
**Solución:** Verificar URL y agregar error handler:
```dart
Image.network(
  url,
  errorBuilder: (_, __, ___) => Icon(Icons.error),
)
```

#### 4. **App lenta en debug**
**Solución:** Probar en release mode:
```bash
flutter run --release
```

### Herramientas de debugging:

**Flutter DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Logs:**
```dart
print('Debug: $variable');
debugPrint('Debug info');
```

**GraphQL Debugging:**
- Habilitar logging en cliente
- Usar Playground de PokéAPI

---

## 📊 Métricas y Performance

### Optimizaciones implementadas:

1. **Caché de GraphQL:**
   - Reduce queries redundantes
   - Mejora tiempo de respuesta
   - Ahorra datos móviles

2. **Paginación infinita:**
   - Carga incremental
   - Mejor rendimiento inicial
   - UX fluida

3. **Imágenes cacheadas:**
   - Cache automático de Flutter
   - Menos descargas repetidas

4. **Modelos ligeros:**
   - `PokemonListItem` vs `PokemonDetail`
   - Solo datos necesarios por pantalla

5. **Lazy loading:**
   - Tabs no cargan hasta ser visibles
   - Widgets construidos on-demand

### Buenas prácticas aplicadas:

- ✅ Separación de responsabilidades
- ✅ DRY (Don't Repeat Yourself)
- ✅ Single Responsibility Principle
- ✅ Widgets const donde es posible
- ✅ Dispose de controladores
- ✅ Error handling consistente

---

## 🔒 Seguridad

### Medidas implementadas:

1. **Contraseñas hasheadas:**
   - SHA-256 antes de almacenar
   - Nunca en texto plano
   - Salt implícito por usuario (email)

2. **Validación de inputs:**
   - Email format check
   - Password strength
   - SQL injection prevention (GraphQL)

3. **Sesiones locales:**
   - No se exponen tokens
   - Cierre de sesión limpio
   - No hay backend vulnerable

### Consideraciones:

- 🔐 Para producción: considerar cifrado de Hive
- 🔐 Para producción: implementar rate limiting
- 🔐 Para producción: añadir autenticación 2FA

---

## 🚀 Próximos Pasos y Mejoras

### Funcionalidades pendientes:

1. **Implementar secciones placeholder:**
   - Moves (Movimientos completos)
   - TM (Máquinas técnicas)
   - Checklists (Tracking)
   - Parties (Equipos)
   - Locations (Mapas)

2. **Favoritos:**
   - Marcar Pokémon favoritos
   - Lista de favoritos
   - Sincronización

3. **Comparador:**
   - Comparar stats de 2+ Pokémon
   - Gráficos comparativos

4. **Búsqueda avanzada:**
   - Por estadísticas
   - Por habilidades
   - Por movimientos

5. **Offline mode:**
   - Caché completo
   - Funcionalidad sin internet

6. **Notificaciones:**
   - Eventos de PokéAPI
   - Recordatorios

### Mejoras técnicas:

1. **Tests:**
   - Unit tests completos
   - Widget tests
   - Integration tests

2. **Internacionalización:**
   - Soporte multi-idioma
   - i18n completo

3. **Accesibilidad:**
   - Screen reader support
   - High contrast mode
   - Font scaling

4. **Analytics:**
   - Firebase Analytics
   - Crash reporting
   - Usage metrics

---

## 📝 Resumen

Esta aplicación es una **Pokédex completa y funcional** construida con Flutter que demuestra:

✅ **Arquitectura limpia** con separación de capas
✅ **GraphQL** para datos en tiempo real
✅ **Hive** para persistencia local
✅ **Material Design** con temas personalizables
✅ **Animaciones** suaves y profesionales
✅ **Performance** optimizada con caché y paginación
✅ **Seguridad** con autenticación local
✅ **Escalabilidad** para futuras funcionalidades

La app es **production-ready** en sus funcionalidades implementadas y provee una base sólida para continuar creciendo.

---

## 🤝 Contribuir

Para contribuir al proyecto:

1. Fork el repositorio
2. Crear feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

---

## 📄 Licencia

Este proyecto es para propósitos educativos.

---

## 📞 Soporte

Para dudas o problemas:
- Abrir un Issue en GitHub
- Revisar documentación de Flutter: https://flutter.dev
- Revisar documentación de PokéAPI: https://pokeapi.co

---

**¡Gracias por usar esta Pokédex! 🎮✨**
