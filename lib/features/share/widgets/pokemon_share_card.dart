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
  });

  final PokemonDetail pokemon;
  final Color themeColor;

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

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: 1080,
          height: 1920,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor, secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- IMAGE ---
                SizedBox(
                  height: 480,
                  child: pokemon.imageUrl.isNotEmpty
                      ? Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.catching_pokemon,
                              size: 400,
                              color: Colors.white.withOpacity(0.5),
                            );
                          },
                        )
                      : Icon(
                          Icons.catching_pokemon,
                          size: 400,
                          color: Colors.white.withOpacity(0.5),
                        ),
                ),

                const SizedBox(height: 32),

                // --- NAME & NUMBER ---
                Column(
                  children: [
                    Text(
                      _formatPokedexNumber(pokemon.id),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _capitalize(pokemon.name),
                      style: const TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --- TYPES ---
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 12,
                  children: pokemon.types.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.25),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // --- DESCRIPTION ---
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.2),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(.25),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    pokemon.description,
                    style: const TextStyle(
                      fontSize: 34,
                      height: 1.35,
                      color: Colors.white,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // --- STATS BOX ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.25),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "STATS",
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _statBar('HP', _getStatValue('hp')),
                      _statBar('ATK', _getStatValue('attack')),
                      _statBar('DEF', _getStatValue('defense')),
                      _statBar('SATK', _getStatValue('special-attack')),
                      _statBar('SDEF', _getStatValue('special-defense')),
                      _statBar('SPD', _getStatValue('speed')),
                    ],
                  ),
                ),

                // --- FOOTER (logo) ---
                Text(
                  "ExploreDex",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBar(String label, int value) {
    final double normalized = (value / 200).clamp(0.0, 1.0);
    final Color barColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 2,
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
                        size: 22,
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
