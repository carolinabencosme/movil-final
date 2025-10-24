import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/ability_model.dart';

class AbilityDetailScreen extends StatelessWidget {
  const AbilityDetailScreen({
    super.key,
    required this.ability,
    this.accentColor = const Color(0xFF9C27B0),
    this.heroTag,
  });

  final AbilitySummary ability;
  final Color accentColor;
  final String? heroTag;

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
        child: Query(
          options: QueryOptions(
            document: gql(_abilityDetailQuery),
            variables: <String, dynamic>{'id': ability.id},
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
          builder: (result, {fetchMore, refetch}) {
            AbilityDetail baseDetail = AbilityDetail(
              id: ability.id,
              name: ability.name,
              displayName: ability.displayName,
              shortEffect: ability.shortEffect,
              fullEffect: ability.fullEffect,
              pokemon: const <AbilityPokemonRef>[],
            );

            if (result.data != null) {
              final abilityData = result.data?['pokemon_v2_ability_by_pk']
                  as Map<String, dynamic>?;
              if (abilityData != null) {
                baseDetail = AbilityDetail.fromGraphQL(abilityData);
              }
            }

            final isLoading = result.isLoading && result.data == null;
            final hasError = result.hasException && result.data == null;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(theme, baseDetail),
                  const SizedBox(height: 24),
                  _buildEffectSection(theme, baseDetail),
                  const SizedBox(height: 24),
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

  Widget _buildHeroCard(ThemeData theme, AbilityDetail detail) {
    return Hero(
      tag: heroTag ?? 'ability-card-${detail.id}',
      child: Material(
        color: Colors.transparent,
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
                          ? 'Sin descripción breve disponible.'
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

  Widget _buildEffectSection(ThemeData theme, AbilityDetail detail) {
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
                'Descripción completa',
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
                ? 'Sin descripción disponible en este idioma.'
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
                'Pokémon que la poseen',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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

class _EmptyPokemonState extends StatelessWidget {
  const _EmptyPokemonState({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                'Pokémon que la poseen',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'No encontramos Pokémon asociados a esta habilidad.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E5E55),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({this.onRetry});

  final Future<QueryResult<Object?>?> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            children: const [
              Icon(Icons.error_outline, color: Color(0xFF9C27B0)),
              SizedBox(width: 12),
              Text(
                'No pudimos cargar los Pokémon asociados.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Intenta nuevamente para ver qué Pokémon cuentan con esta habilidad.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6E5E55),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onRetry == null
                  ? null
                  : () async {
                      await onRetry!.call();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}
