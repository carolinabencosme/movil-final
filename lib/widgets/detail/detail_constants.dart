import 'dart:ui' show clampDouble;
import 'package:flutter/material.dart';

/// Emojis de tipos para representación visual de los tipos de Pokémon
/// 
/// Mapea cada tipo de Pokémon a un emoji representativo que se usa
/// en las tarjetas de movimientos y otras partes de la UI.
const Map<String, String> typeEmojis = {
  'normal': '⭐️',
  'fire': '🔥',
  'water': '💧',
  'electric': '⚡️',
  'grass': '🍃',
  'ice': '❄️',
  'fighting': '🥊',
  'poison': '☠️',
  'ground': '🌋',
  'flying': '🕊️',
  'psychic': '🔮',
  'bug': '🐛',
  'rock': '🪨',
  'ghost': '👻',
  'dragon': '🐲',
  'dark': '🌑',
  'steel': '⚙️',
  'fairy': '🧚',
};

/// IDs de idiomas preferidos: ES (7) y EN (9)
/// 
/// Se usan en las queries GraphQL para obtener nombres y descripciones
/// en español primero, con inglés como respaldo.
const List<int> preferredLanguageIds = [7, 9];

/// Textura SVG de fondo para la pantalla de detalles
/// 
/// SVG decorativo que se muestra en el header del Pokémon con
/// círculos concéntricos y líneas que le dan un aspecto tecnológico.
const String backgroundTextureSvg = '''
<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="halo" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0%" stop-color="white" stop-opacity="0.32"/>
      <stop offset="100%" stop-color="white" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <g fill="none" stroke="white" stroke-width="12" stroke-linecap="round" stroke-opacity="0.18">
    <path d="M50 200h300"/>
    <path d="M200 50v300"/>
    <circle cx="200" cy="200" r="160"/>
    <circle cx="200" cy="200" r="110" stroke-opacity="0.12" stroke-width="10"/>
    <circle cx="200" cy="200" r="60" stroke-opacity="0.1" stroke-width="8"/>
  </g>
  <circle cx="200" cy="200" r="48" fill="url(#halo)"/>
</svg>
''';

/// Configuration for detail screen tabs
class DetailTabConfig {
  const DetailTabConfig({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Tab configurations
const List<DetailTabConfig> detailTabConfigs = [
  DetailTabConfig(icon: Icons.info_outline_rounded, label: 'Información'),
  DetailTabConfig(icon: Icons.bar_chart_rounded, label: 'Estadísticas'),
  DetailTabConfig(icon: Icons.auto_awesome_motion_rounded, label: 'Matchups'),
  DetailTabConfig(icon: Icons.transform_rounded, label: 'Evoluciones'),
  DetailTabConfig(icon: Icons.sports_martial_arts_rounded, label: 'Movimientos'),
];

// Constants for evolution stage card sizing
const double evolutionCardImageSizeNormal = 110.0;
const double evolutionCardImageSizeCompact = 90.0;
const double evolutionCardImageBorderRadiusNormal = 24.0;
const double evolutionCardImageBorderRadiusCompact = 20.0;
const double evolutionCardImagePaddingNormal = 12.0;
const double evolutionCardImagePaddingCompact = 8.0;
const double evolutionCardHorizontalPaddingNormal = 18.0;
const double evolutionCardHorizontalPaddingCompact = 14.0;
const double evolutionCardVerticalPaddingNormal = 16.0;
const double evolutionCardVerticalPaddingCompact = 12.0;
const double evolutionCardBorderRadiusNormal = 26.0;
const double evolutionCardBorderRadiusCompact = 20.0;
const double evolutionCardNameFontSizeCompact = 14.0;
const double evolutionCardConditionFontSizeCompact = 12.0;
const double evolutionCardConditionDetailFontSizeCompact = 11.0;

// Constants for horizontal evolution layout
const double horizontalEvolutionCardMinWidth = 160.0;
const double horizontalEvolutionCardMaxWidth = 220.0;
const double horizontalEvolutionPadding = 100.0;
const double horizontalArrowTranslationDistance = 4.0;
const int horizontalEvolutionMaxStages = 3;

/// Global map for tracking pending evolution navigation
final Map<String, int> pendingEvolutionNavigation = <String, int>{};

/// Calculates responsive padding for detail tabs based on screen size
EdgeInsets responsiveDetailTabPadding(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final horizontalPadding = clampDouble(size.width * 0.06, 16, 32);
  return EdgeInsets.symmetric(horizontal: horizontalPadding)
      .copyWith(top: 24, bottom: 32);
}
