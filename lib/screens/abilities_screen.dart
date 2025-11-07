import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/ability_model.dart';
import '../queries/get_pokemon_abilities.dart';
import 'ability_detail_screen.dart';

/// Pantalla que lista habilidades de Pokémon usando GraphQL + cache de `graphql_flutter`.
/// - Trae todas las habilidades (EN/ES) con `getPokemonAbilitiesQuery`.
/// - Permite buscar por nombre (displayName o name).
/// - Muestra estados de carga, vacío y error.
/// - Navega a un detalle con animaciones (Hero + Fade).
class AbilitiesScreen extends StatefulWidget {
  const AbilitiesScreen({
    super.key,
    this.heroTag,
    this.accentColor,
    this.title = 'Abilities',
  });
  /// Tag para la transición Hero del título (opcional).
  final String? heroTag;
  /// Color de acento para AppBar y estilos de la lista (opcional).
  final Color? accentColor;
  /// Título de la pantalla.
  final String title;

  @override
  State<AbilitiesScreen> createState() => _AbilitiesScreenState();
}

class _AbilitiesScreenState extends State<AbilitiesScreen> {
  /// Controlador del campo de búsqueda (se limpia en `dispose`).
  final TextEditingController _searchController = TextEditingController();
  /// Término actual de búsqueda (minúsculas y sin espacios laterales).
  String _searchTerm = '';

  @override
  void dispose() {
    // Evita memory leaks del TextEditingController.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? const Color(0xFF9C27B0);
    final heroTag = widget.heroTag;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E7),
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: heroTag != null
        // Cuando hay heroTag, animamos el título entre pantallas.
            ? Hero(
                tag: heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
        // Sin heroTag, título simple.
            : Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de búsqueda (actualiza _searchTerm en onChanged).
            _buildSearchBar(theme),
            // Contenido principal: Query de GraphQL + lista de resultados.
            Expanded(
              child: Query(
                options: QueryOptions(
                  // Document de la query (nombres + efectos EN/ES).
                  document: gql(getPokemonAbilitiesQuery),
                  // Estrategia: usa cache inmediatamente y luego red consulta (UX fluida).
                  fetchPolicy: FetchPolicy.cacheAndNetwork,
                ),
                builder: (result, {fetchMore, refetch}) {
                  // Datos crudos de la respuesta (o lista vacía en error/primer render).
                  final abilitiesData =
                      result.data?['pokemon_v2_ability'] as List<dynamic>? ??
                          <dynamic>[];
                  // Si hubo excepción y no hay datos en cache → mostrar estado de error con retry.
                  if (result.hasException && abilitiesData.isEmpty) {
                    return _AbilitiesErrorState(
                      message: 'No se pudieron cargar las habilidades.',
                      onRetry: refetch,
                    );
                  }
                  // Parseo a modelo de dominio (AbilitySummary).
                  final abilities = abilitiesData
                      .map((dynamic entry) => AbilitySummary.fromGraphQL(
                          entry as Map<String, dynamic>))
                      .toList();

                  // Filtro local por término de búsqueda en displayName o name.
                  final filteredAbilities = abilities.where((ability) {
                    if (_searchTerm.isEmpty) return true;
                    final term = _searchTerm.toLowerCase();
                    return ability.displayName.toLowerCase().contains(term) ||
                        ability.name.toLowerCase().contains(term);
                  }).toList();

                  // Indicador de carga inicial (cuando no hay cache aún).
                  if (result.isLoading && abilities.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
                    );
                  }

                  // Estado vacío: no hay resultados (por búsqueda o porque no hay datos).
                  if (filteredAbilities.isEmpty) {
                    return _AbilitiesEmptyState(
                      isSearching: _searchTerm.isNotEmpty,
                    );
                  }
                  // Lista con pull-to-refresh (llama a `refetch` si existe).
                  return RefreshIndicator(
                    color: accentColor,
                    onRefresh: () async {
                      if (refetch != null) {
                        await refetch();
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final ability = filteredAbilities[index];
                        final heroTag = 'ability-card-${ability.id}';
                        // Aparición con Tween (fade + translate) para UX más viva.
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 400 + index * 60),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _AbilityCard(
                            ability: ability,
                            accentColor: accentColor,
                            heroTag: heroTag,
                            onTap: () {
                              // Navegación hacia la pantalla de detalle con transición fade.
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                  pageBuilder: (_, animation, secondaryAnimation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: AbilityDetailScreen(
                                        ability: ability,
                                        accentColor: accentColor,
                                        heroTag: heroTag,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      // Espaciado entre cards.
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemCount: filteredAbilities.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la barra de búsqueda con estilo y comportamiento.
  /// - Actualiza `_searchTerm` en cada cambio para re-filtrar la lista.
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchTerm = value.trim());
        },
        decoration: InputDecoration(
          hintText: 'Buscar habilidad...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
/// Card de habilidad en la lista:
/// - Muestra `displayName` y `shortEffect`.
/// - Tiene fondo con gradiente, shadow suave y leading icon.
/// - Usa `Hero` para transiciones fluidas hacia la pantalla de detalle.

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({
    required this.ability,
    required this.accentColor,
    required this.heroTag,
    required this.onTap,
  });

  final AbilitySummary ability;
  final Color accentColor;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFDF6E4),
                  const Color(0xFFF5E6CC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon container de color de acento (consistente con AppBar).
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nombre localizado en negrita.
                    Expanded(
                      child: Text(
                        ability.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A3F35),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Descripción corta o fallback si no hay texto.
                Text(
                  ability.shortEffect.isEmpty
                      ? 'Sin descripción disponible.'
                      : ability.shortEffect,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6E5E55),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vista de error con mensaje y botón de reintento.
/// - Usa `refetch` de graphql_flutter para reintentar la query.

class _AbilitiesErrorState extends StatelessWidget {
  const _AbilitiesErrorState({
    required this.message,
    this.onRetry,
  });

  final String message;
  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF9C27B0), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6E5E55),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: retry == null
                  ? null
                  : () async {
                      await retry();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista vacía para dos escenarios:
/// - `isSearching == true`: el término no encontró coincidencias.
/// - `isSearching == false`: no hay habilidades disponibles todavía.

class _AbilitiesEmptyState extends StatelessWidget {
  const _AbilitiesEmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.auto_awesome,
              color: const Color(0xFFBCAAA4),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No encontramos habilidades que coincidan con tu búsqueda.'
                  : 'No hay habilidades disponibles en este momento.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6E5E55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
