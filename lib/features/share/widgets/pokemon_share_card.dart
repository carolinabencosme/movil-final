import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../models/pokemon_model.dart';
import '../../../theme/pokemon_type_colors.dart';

/// Widget que renderiza una tarjeta visual moderna y profesional
/// para compartir como imagen en redes sociales.
/// 
/// La tarjeta incluye:
/// - Fondo degradado según tipo del Pokémon
/// - Imagen oficial del Pokémon centrada
/// - Número en la Pokédex (#001, #025…)
/// - Nombre del Pokémon
/// - Tipos con chips semi-transparentes
/// - Descripción del Pokémon
/// - Stats completas (HP, ATK, DEF, SATK, SDEF, SPD) con barras
/// - Logo de la Pokédex en el footer
class PokemonShareCard extends StatelessWidget {
  const PokemonShareCard({
    super.key,
    required this.pokemon,
    required this.themeColor,
    this.fixedSize,
  });

  final PokemonDetail pokemon;
  final Color themeColor;
  final Size? fixedSize;

  /// Formatea el ID del Pokémon como número de Pokédex (#001, #025...)
  String _formatPokedexNumber(int id) {
    return '#${id.toString().padLeft(3, '0')}';
  }

  /// Capitaliza la primera letra del texto
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Determinar color secundario para el degradado
    final secondaryColor = pokemon.types.length > 1
        ? (pokemonTypeColors[pokemon.types[1].toLowerCase()] ?? themeColor)
        : themeColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        const Size baseSize = Size(1080, 1920);
        final mediaSize = MediaQuery.sizeOf(context);

        final Size resolvedSize;
        final double scale;

        if (fixedSize != null) {
          resolvedSize = fixedSize!;
          scale = 1.0;
        } else {
          final double availableHeight = constraints.maxHeight.isFinite &&
                  constraints.maxHeight > 0
              ? constraints.maxHeight
              : mediaSize.height;
          final double availableWidth = constraints.maxWidth.isFinite &&
                  constraints.maxWidth > 0
              ? constraints.maxWidth
              : mediaSize.width;

          final double heightScale =
              (availableHeight / baseSize.height).clamp(0.45, 1.0);
          final double widthScale =
              (availableWidth / baseSize.width).clamp(0.45, 1.0);
          scale = math.min(heightScale, widthScale);
          resolvedSize =
              Size(baseSize.width * scale, baseSize.height * scale);
        }

        double scaled(double value) => value * scale;

        return Center(
          child: Container(
            width: resolvedSize.width,
            height: resolvedSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor, secondaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(scaled(40)),
            ),
            child: LayoutBuilder(
              builder: (context, innerConstraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaled(60),
                    vertical: scaled(60),
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: innerConstraints.maxHeight - scaled(120),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- IMAGE ---
                          SizedBox(
                            height: scaled(480),
                            child: pokemon.imageUrl.isNotEmpty
                                ? Image.network(
                                    pokemon.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.catching_pokemon,
                                        size: scaled(400),
                                        color: Colors.white.withOpacity(0.5),
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.catching_pokemon,
                                    size: scaled(400),
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                          ),

                          SizedBox(height: scaled(32)),

                          // --- NAME & NUMBER ---
                          Column(
                            children: [
                              Text(
                                _formatPokedexNumber(pokemon.id),
                                style: TextStyle(
                                  fontSize: scaled(64),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                _capitalize(pokemon.name),
                                style: TextStyle(
                                  fontSize: scaled(110),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          SizedBox(height: scaled(28)),

                          // --- TYPES ---
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: scaled(20),
                            runSpacing: scaled(12),
                            children: pokemon.types.map((type) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: scaled(32),
                                  vertical: scaled(16),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.25),
                                  borderRadius: BorderRadius.circular(scaled(40)),
                                ),
                                child: Text(
                                  type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: scaled(36),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: scaled(32)),

                          // --- DESCRIPTION ---
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: scaled(28),
                              vertical: scaled(24),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.2),
                              borderRadius: BorderRadius.circular(scaled(32)),
                              border: Border.all(
                                color: Colors.white.withOpacity(.25),
                                width: scaled(2),
                              ),
                            ),
                            child: Text(
                              pokemon.description,
                              style: TextStyle(
                                fontSize: scaled(34),
                                height: 1.35,
                                color: Colors.white,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: scaled(32)),

                          // --- STATS BOX ---
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(scaled(32)),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.25),
                              borderRadius: BorderRadius.circular(scaled(40)),
                              border: Border.all(
                                color: Colors.white.withOpacity(.2),
                                width: scaled(2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "STATS",
                                  style: TextStyle(
                                    fontSize: scaled(46),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: scaled(18)),
                                _statBar('HP', _getStatValue('hp'), scale),
                                _statBar('ATK', _getStatValue('attack'), scale),
                                _statBar('DEF', _getStatValue('defense'), scale),
                                _statBar(
                                    'SATK', _getStatValue('special-attack'), scale),
                                _statBar(
                                    'SDEF', _getStatValue('special-defense'), scale),
                                _statBar('SPD', _getStatValue('speed'), scale),
                              ],
                            ),
                          ),

                          // --- FOOTER (logo) ---
                          Text(
                            "ExploreDex",
                            style: TextStyle(
                              fontSize: scaled(42),
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _statBar(String label, int value, double scale) {
    final double normalized = (value / 200).clamp(0.0, 1.0);
    final Color barColor = Colors.white;

    double scaled(double value) => value * scale;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaled(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: scaled(42),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: scaled(48),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: scaled(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(scaled(18)),
            child: Container(
              height: scaled(36),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(scaled(18)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: scaled(2),
                ),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: normalized,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            barColor.withOpacity(0.9),
                            barColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: scaled(22),
                        color: normalized > 0
                            ? Colors.black.withOpacity(0.6)
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el valor de una estadística por nombre
  int _getStatValue(String statName) {
    final stat = pokemon.stats.firstWhere(
      (s) => s.name == statName,
      orElse: () => const PokemonStat(name: '', baseStat: 0),
    );
    return stat.baseStat;
  }
}
