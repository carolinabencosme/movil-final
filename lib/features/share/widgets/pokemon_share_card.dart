import 'package:flutter/material.dart';
import '../../../models/pokemon_model.dart';
import '../../../theme/pokemon_type_colors.dart';

/// Widget que renderiza una tarjeta visual estilo "Pokémon Trading Card"
/// para compartir como imagen en redes sociales.
/// 
/// La tarjeta incluye:
/// - Imagen oficial del Pokémon
/// - Nombre
/// - Número en la Pokédex (#001, #025…)
/// - Tipos con colores
/// - Stats principales (opcional)
/// - Fondo temático según tipo
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

  /// Determina si usar texto oscuro o claro según el brillo del fondo
  Color _getContrastingTextColor(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getContrastingTextColor(themeColor);
    final accentColor = textColor.withOpacity(0.7);

    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor,
            Color.alphaBlend(
              themeColor.withOpacity(0.7),
              Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header: Nombre y número
            Column(
              children: [
                Text(
                  _capitalize(pokemon.name),
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _formatPokedexNumber(pokemon.id),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),

            // Imagen del Pokémon (centrada)
            Expanded(
              child: Center(
                child: Container(
                  width: 800,
                  height: 800,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: pokemon.imageUrl.isNotEmpty
                        ? Image.network(
                            pokemon.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.catching_pokemon,
                                size: 400,
                                color: textColor.withOpacity(0.5),
                              );
                            },
                          )
                        : Icon(
                            Icons.catching_pokemon,
                            size: 400,
                            color: textColor.withOpacity(0.5),
                          ),
                  ),
                ),
              ),
            ),

            // Footer: Tipos y stats
            Column(
              children: [
                // Tipos
                if (pokemon.types.isNotEmpty)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: pokemon.types.map((type) {
                      final typeColor = pokemonTypeColors[type.toLowerCase()] ??
                          Colors.grey;
                      final typeTextColor = _getContrastingTextColor(typeColor);
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(64),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _capitalize(type),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: typeTextColor,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 48),

                // Stats principales (HP, ATK, DEF)
                if (pokemon.stats.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _buildMainStats(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye los widgets para las stats principales
  List<Widget> _buildMainStats() {
    final statNames = ['hp', 'attack', 'defense'];
    final statLabels = {'hp': 'HP', 'attack': 'ATK', 'defense': 'DEF'};
    final textColor = _getContrastingTextColor(themeColor);
    
    return statNames.map((statName) {
      final stat = pokemon.stats.firstWhere(
        (s) => s.name == statName,
        orElse: () => const PokemonStat(name: '', baseStat: 0),
      );

      return Column(
        children: [
          Text(
            statLabels[statName] ?? statName.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.7),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat.baseStat.toString(),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      );
    }).toList();
  }
}
