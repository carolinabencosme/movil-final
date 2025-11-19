import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/ability_model.dart';

/// Pantalla de detalle para una habilidad de Pokémon.
/// - Recibe un `AbilitySummary` base (nombre/ids/textos ya listos para mostrar).
/// - Lanza una query por `id` para completar datos (descripción completa y lista de Pokémon que la tienen).
/// - Usa `graphql_flutter` con `cacheAndNetwork` para UX fluida (muestra cache y luego refresca).

class AbilityDetailScreen extends StatelessWidget {
  const AbilityDetailScreen({
    super.key,
    required this.ability,
    this.accentColor = const Color(0xFF9C27B0),
    this.heroTag,
  });

  /// Resumen a partir del cual renderizamos inmediatamente (optimiza primer paint).
  final AbilitySummary ability;
  /// Color de acento para AppBar y componentes de esta vista.
  final Color accentColor;
  /// Tag opcional para transición Hero sincronizada con la lista.
  final String? heroTag;

  /// Query: detalle por PK (id) con nombres EN/ES, textos de efecto EN/ES, y Pokémon que poseen la habilidad.
  static const String _abilityDetailQuery = r'''
    query AbilityDetail($id: Int!) {
      pokemon_v2_ability_by_pk(id: $id) {
        id
        name
        pokemon_v2_abilitynames(where: {language_id: {_in: [7, 9]}}) {
          language_id
          name
        }
        pokemon_v2_abilityeffecttexts(where: {language_id: {_in: [7, 9]}}) {
          language_id
          short_effect
          effect
        }
        pokemon_v2_pokemonabilities(order_by: {pokemon_v2_pokemon: {name: asc}}) {
          pokemon_v2_pokemon {
            id
            name
          }
        }
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E7),
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: Text(
          ability.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        // Query ejecutada con el id de la habilidad; cache primero y luego red.
      child: Query(
          options: QueryOptions(
            document: gql(_abilityDetailQuery),
            variables: <String, dynamic>{'id': ability.id},
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (result, {fetchMore, refetch}) {
            // Creamos un detalle base usando el summary para evitar pantallas en blanco.
            AbilityDetail baseDetail = AbilityDetail(
              id: ability.id,
              name: ability.name,
              displayName: ability.displayName,
              shortEffect: ability.shortEffect,
              fullEffect: ability.fullEffect,
              pokemon: const <AbilityPokemonRef>[],
            );

            // Si llega data, parseamos el detalle “real” desde GraphQL.
            if (result.data != null) {
              final abilityData = result.data?['pokemon_v2_ability_by_pk']
                  as Map<String, dynamic>?;
              if (abilityData != null) {
                baseDetail = AbilityDetail.fromGraphQL(abilityData);
              }
            }

            // Flags de estado de red para decidir qué UI mostrar.
            final isLoading = result.isLoading && result.data == null;
            final hasError = result.hasException && result.data == null;

            // Contenido desplazable: hero card, descripción completa y lista de Pokémon (o estados).
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(context, baseDetail),
                  const SizedBox(height: 24),
                  _buildEffectSection(context, baseDetail),
                  const SizedBox(height: 24),
                  // Manejo de estados: error → retry, loading → spinner, ok → lista o vacío.
                  if (hasError)
                    _DetailErrorState(onRetry: refetch)
                  else if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child:
                            CircularProgressIndicator(color: Color(0xFF9C27B0)),
                      ),
                    )
                  else
                  // Cambios suaves entre “vacío” y “lista” cuando llega la data.

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: baseDetail.pokemon.isEmpty
                          ? _EmptyPokemonState(accentColor: accentColor)
                          : _PokemonList(
                              detail: baseDetail,
                              accentColor: accentColor,
                            ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tarjeta superior con transición Hero que muestra nombre y shortEffect.
  /// Sirve para dar continuidad visual desde la lista de habilidades.
  Widget _buildHeroCard(BuildContext context, AbilityDetail detail) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Hero(
      tag: heroTag ?? 'ability-card-${detail.id}',
      child: Material(
        color: Colors.transparent,
        // Ícono/Avatar de la habilidad con color de acento.
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFDF6E4),
                Color(0xFFF5E6CC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              // Nombre + descripción corta (fallback si no hay texto).
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF4A3F35),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.shortEffect.isEmpty
                          ? l10n.abilitiesNoShortDescription
                          : detail.shortEffect,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6E5E55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sección con la descripción completa de la habilidad (`fullEffect`).
  /// Envuelta en un contenedor con sombra y títulos consistentes con la UI.
  Widget _buildEffectSection(BuildContext context, AbilityDetail detail) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: accentColor),
              const SizedBox(width: 12),
              Text(
                l10n.abilitiesFullDescriptionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            detail.fullEffect.isEmpty
                ? l10n.abilitiesFullDescriptionFallback
                : detail.fullEffect,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4A3F35),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
/// Lista de Pokémon que poseen la habilidad, presentada como chips.
/// Renderiza un contenedor estilizado y usa `formattedName` para capitalizar.
class _PokemonList extends StatelessWidget {
  const _PokemonList({
    required this.detail,
    required this.accentColor,
  });

  final AbilityDetail detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.catching_pokemon, color: accentColor),
              const SizedBox(width: 12),
              Text(
                l10n.abilitiesPokemonSectionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chips responsivos (Wrap) para una grilla fluida.
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: detail.pokemon
                .map((ref) => Chip(
                      label: Text(ref.formattedName),
                      backgroundColor: const Color(0xFFF3E5F5),
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4A3F35),
                        fontWeight: FontWeight.w600,
                      ),
                      avatar: CircleAvatar(
                        backgroundColor: accentColor.withOpacity(0.2),
                        child: Text(
                          ref.name.isNotEmpty
                              ? ref.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Color(0xFF4A3F35)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
/// Estado vacío cuando la habilidad no está asociada a ningún Pokémon.
/// Mantiene el mismo estilo de tarjeta para consistencia visual.
class _EmptyPokemonState extends StatelessWidget {
  const _EmptyPokemonState({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.catching_pokemon, color: accentColor),
              const SizedBox(width: 12),
              Text(
                l10n.abilitiesPokemonSectionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.abilitiesPokemonEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E5E55),
            ),
          ),
        ],
      ),
    );
  }
}
/// Estado de error para la sección de Pokémon asociados.
/// Provee un botón de reintento que ejecuta `refetch` de `graphql_flutter`.
class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({this.onRetry});

  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final retry = onRetry;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x339C27B0),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFF9C27B0)),
              const SizedBox(width: 12),
              Text(
                l10n.abilitiesPokemonErrorTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.abilitiesPokemonErrorDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E5E55),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: retry == null
                  ? null
                  : () async {
                      await retry();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ),
        ],
      ),
    );
  }
}
