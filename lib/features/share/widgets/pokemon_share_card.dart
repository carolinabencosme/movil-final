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
/// - Stats principales (HP, ATK, DEF, SPD)
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
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- IMAGE ---
                SizedBox(
                  height: 600,
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

                // --- NAME & NUMBER ---
                Column(
                  children: [
                    Text(
                      _formatPokedexNumber(pokemon.id),
                      style: const TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _capitalize(pokemon.name),
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

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
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // --- STATS BOX ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.25),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "STATS",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 40,
                        runSpacing: 20,
                        children: [
                          _statColumn("HP", _getStatValue("hp")),
                          _statColumn("ATK", _getStatValue("attack")),
                          _statColumn("DEF", _getStatValue("defense")),
                          _statColumn("SPD", _getStatValue("speed")),
                        ],
                      )
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

  Widget _statColumn(String title, int value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 70,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
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
