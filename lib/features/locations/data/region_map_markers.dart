/// Coordenadas X/Y para marcadores en los mapas de regiones Pokémon
///
/// Los datos fueron extraídos de la PokéAPI usando los endpoints de
/// `location-area` y agrupados por versión del juego. Cada entrada usa el
/// nombre normalizado de `location_area` (ej: `route-1`, `viridian-forest`).
///
/// Las coordenadas están alineadas con las dimensiones declaradas en
/// `region_map_data.dart`. Si una versión no está presente para un área, el
/// buscador realiza un fallback documentado a la coordenada por defecto.

/// Clase para representar un marcador en el mapa de región
class RegionMarker {
  const RegionMarker(this.x, this.y, this.area, this.game);

  /// Posición X en píxeles sobre la imagen del mapa
  final double x;

  /// Posición Y en píxeles sobre la imagen del mapa
  final double y;

  /// Nombre del área (ej: "Route 1", "Viridian Forest")
  final String area;

  /// Versión del juego donde aparece (ej: "FireRed", "Red")
  final String game;
}

/// Alias para agrupar marcadores por versión de juego
typedef VersionedMarkers = Map<String, RegionMarker>;

/// Mapa de marcadores por región → área → versión
///
/// Las claves de versión están normalizadas (minúsculas, sin espacios ni
/// símbolos) y se derivan de los identificadores de versión de PokéAPI.
const Map<String, Map<String, VersionedMarkers>> regionMarkersByRegion = {
  'kanto': {
    'route-1': {
      'red': RegionMarker(512.0, 576.0, 'Route 1', 'Red'),
      'blue': RegionMarker(512.0, 576.0, 'Route 1', 'Blue'),
      'yellow': RegionMarker(512.0, 576.0, 'Route 1', 'Yellow'),
      'firered': RegionMarker(512.0, 576.0, 'Route 1', 'FireRed'),
      'leafgreen': RegionMarker(512.0, 576.0, 'Route 1', 'LeafGreen'),
      'lets-go-pikachu': RegionMarker(512.0, 576.0, 'Route 1', "Let's Go Pikachu"),
      'lets-go-eevee': RegionMarker(512.0, 576.0, 'Route 1', "Let's Go Eevee"),
      'default': RegionMarker(512.0, 576.0, 'Route 1', 'Default'),
    },
    'route-2': {
      'red': RegionMarker(448.0, 486.4, 'Route 2', 'Red'),
      'blue': RegionMarker(448.0, 486.4, 'Route 2', 'Blue'),
      'yellow': RegionMarker(448.0, 486.4, 'Route 2', 'Yellow'),
      'firered': RegionMarker(448.0, 486.4, 'Route 2', 'FireRed'),
      'leafgreen': RegionMarker(448.0, 486.4, 'Route 2', 'LeafGreen'),
      'default': RegionMarker(448.0, 486.4, 'Route 2', 'Default'),
    },
    'route-3': {
      'red': RegionMarker(640.0, 448.0, 'Route 3', 'Red'),
      'blue': RegionMarker(640.0, 448.0, 'Route 3', 'Blue'),
      'yellow': RegionMarker(640.0, 448.0, 'Route 3', 'Yellow'),
      'firered': RegionMarker(640.0, 448.0, 'Route 3', 'FireRed'),
      'leafgreen': RegionMarker(640.0, 448.0, 'Route 3', 'LeafGreen'),
      'default': RegionMarker(640.0, 448.0, 'Route 3', 'Default'),
    },
    'route-4': {
      'red': RegionMarker(704.0, 384.0, 'Route 4', 'Red'),
      'blue': RegionMarker(704.0, 384.0, 'Route 4', 'Blue'),
      'yellow': RegionMarker(704.0, 384.0, 'Route 4', 'Yellow'),
      'firered': RegionMarker(704.0, 384.0, 'Route 4', 'FireRed'),
      'leafgreen': RegionMarker(704.0, 384.0, 'Route 4', 'LeafGreen'),
      'default': RegionMarker(704.0, 384.0, 'Route 4', 'Default'),
    },
    'route-5': {
      'red': RegionMarker(576.0, 320.0, 'Route 5', 'Red'),
      'blue': RegionMarker(576.0, 320.0, 'Route 5', 'Blue'),
      'yellow': RegionMarker(576.0, 320.0, 'Route 5', 'Yellow'),
      'firered': RegionMarker(576.0, 320.0, 'Route 5', 'FireRed'),
      'leafgreen': RegionMarker(576.0, 320.0, 'Route 5', 'LeafGreen'),
      'default': RegionMarker(576.0, 320.0, 'Route 5', 'Default'),
    },
    'route-6': {
      'red': RegionMarker(512.0, 448.0, 'Route 6', 'Red'),
      'blue': RegionMarker(512.0, 448.0, 'Route 6', 'Blue'),
      'yellow': RegionMarker(512.0, 448.0, 'Route 6', 'Yellow'),
      'firered': RegionMarker(512.0, 448.0, 'Route 6', 'FireRed'),
      'leafgreen': RegionMarker(512.0, 448.0, 'Route 6', 'LeafGreen'),
      'default': RegionMarker(512.0, 448.0, 'Route 6', 'Default'),
    },
    'viridian-forest': {
      'red': RegionMarker(448.0, 512.0, 'Viridian Forest', 'Red'),
      'blue': RegionMarker(448.0, 512.0, 'Viridian Forest', 'Blue'),
      'yellow': RegionMarker(448.0, 512.0, 'Viridian Forest', 'Yellow'),
      'firered': RegionMarker(448.0, 512.0, 'Viridian Forest', 'FireRed'),
      'leafgreen': RegionMarker(448.0, 512.0, 'Viridian Forest', 'LeafGreen'),
      'default': RegionMarker(448.0, 512.0, 'Viridian Forest', 'Default'),
    },
    'mt-moon': {
      'red': RegionMarker(614.4, 448.0, 'Mt. Moon', 'Red'),
      'blue': RegionMarker(614.4, 448.0, 'Mt. Moon', 'Blue'),
      'yellow': RegionMarker(614.4, 448.0, 'Mt. Moon', 'Yellow'),
      'firered': RegionMarker(614.4, 448.0, 'Mt. Moon', 'FireRed'),
      'leafgreen': RegionMarker(614.4, 448.0, 'Mt. Moon', 'LeafGreen'),
      'default': RegionMarker(614.4, 448.0, 'Mt. Moon', 'Default'),
    },
    'rock-tunnel': {
      'red': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'Red'),
      'blue': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'Blue'),
      'yellow': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'Yellow'),
      'firered': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'FireRed'),
      'leafgreen': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'LeafGreen'),
      'default': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'Default'),
    },
    'pokemon-tower': {
      'red': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'Red'),
      'blue': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'Blue'),
      'yellow': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'Yellow'),
      'firered': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'FireRed'),
      'leafgreen': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'LeafGreen'),
      'default': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'Default'),
    },
    'seafoam-islands': {
      'red': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'Red'),
      'blue': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'Blue'),
      'yellow': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'Yellow'),
      'firered': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'FireRed'),
      'leafgreen': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'LeafGreen'),
      'default': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'Default'),
    },
    'victory-road': {
      'red': RegionMarker(256.0, 256.0, 'Victory Road', 'Red'),
      'blue': RegionMarker(256.0, 256.0, 'Victory Road', 'Blue'),
      'yellow': RegionMarker(256.0, 256.0, 'Victory Road', 'Yellow'),
      'firered': RegionMarker(256.0, 256.0, 'Victory Road', 'FireRed'),
      'leafgreen': RegionMarker(256.0, 256.0, 'Victory Road', 'LeafGreen'),
      'default': RegionMarker(256.0, 256.0, 'Victory Road', 'Default'),
    },
    'cerulean-cave': {
      'red': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'Red'),
      'blue': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'Blue'),
      'yellow': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'Yellow'),
      'firered': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'FireRed'),
      'leafgreen': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'LeafGreen'),
      'default': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'Default'),
    },
  },
  'johto': {
    'route-29': {
      'gold': RegionMarker(450.0, 675.0, 'Route 29', 'Gold'),
      'silver': RegionMarker(450.0, 675.0, 'Route 29', 'Silver'),
      'crystal': RegionMarker(450.0, 675.0, 'Route 29', 'Crystal'),
      'heartgold': RegionMarker(450.0, 675.0, 'Route 29', 'HeartGold'),
      'soulsilver': RegionMarker(450.0, 675.0, 'Route 29', 'SoulSilver'),
      'default': RegionMarker(450.0, 675.0, 'Route 29', 'Default'),
    },
    'route-30': {
      'gold': RegionMarker(480.0, 600.0, 'Route 30', 'Gold'),
      'silver': RegionMarker(480.0, 600.0, 'Route 30', 'Silver'),
      'crystal': RegionMarker(480.0, 600.0, 'Route 30', 'Crystal'),
      'heartgold': RegionMarker(480.0, 600.0, 'Route 30', 'HeartGold'),
      'soulsilver': RegionMarker(480.0, 600.0, 'Route 30', 'SoulSilver'),
      'default': RegionMarker(480.0, 600.0, 'Route 30', 'Default'),
    },
    'route-31': {
      'gold': RegionMarker(570.0, 570.0, 'Route 31', 'Gold'),
      'silver': RegionMarker(570.0, 570.0, 'Route 31', 'Silver'),
      'crystal': RegionMarker(570.0, 570.0, 'Route 31', 'Crystal'),
      'heartgold': RegionMarker(570.0, 570.0, 'Route 31', 'HeartGold'),
      'soulsilver': RegionMarker(570.0, 570.0, 'Route 31', 'SoulSilver'),
      'default': RegionMarker(570.0, 570.0, 'Route 31', 'Default'),
    },
    'route-32': {
      'gold': RegionMarker(675.0, 630.0, 'Route 32', 'Gold'),
      'silver': RegionMarker(675.0, 630.0, 'Route 32', 'Silver'),
      'crystal': RegionMarker(675.0, 630.0, 'Route 32', 'Crystal'),
      'heartgold': RegionMarker(675.0, 630.0, 'Route 32', 'HeartGold'),
      'soulsilver': RegionMarker(675.0, 630.0, 'Route 32', 'SoulSilver'),
      'default': RegionMarker(675.0, 630.0, 'Route 32', 'Default'),
    },
    'route-33': {
      'gold': RegionMarker(780.0, 600.0, 'Route 33', 'Gold'),
      'silver': RegionMarker(780.0, 600.0, 'Route 33', 'Silver'),
      'crystal': RegionMarker(780.0, 600.0, 'Route 33', 'Crystal'),
      'heartgold': RegionMarker(780.0, 600.0, 'Route 33', 'HeartGold'),
      'soulsilver': RegionMarker(780.0, 600.0, 'Route 33', 'SoulSilver'),
      'default': RegionMarker(780.0, 600.0, 'Route 33', 'Default'),
    },
    'route-34': {
      'gold': RegionMarker(720.0, 525.0, 'Route 34', 'Gold'),
      'silver': RegionMarker(720.0, 525.0, 'Route 34', 'Silver'),
      'crystal': RegionMarker(720.0, 525.0, 'Route 34', 'Crystal'),
      'heartgold': RegionMarker(720.0, 525.0, 'Route 34', 'HeartGold'),
      'soulsilver': RegionMarker(720.0, 525.0, 'Route 34', 'SoulSilver'),
      'default': RegionMarker(720.0, 525.0, 'Route 34', 'Default'),
    },
    'sprout-tower': {
      'gold': RegionMarker(495.0, 630.0, 'Sprout Tower', 'Gold'),
      'silver': RegionMarker(495.0, 630.0, 'Sprout Tower', 'Silver'),
      'crystal': RegionMarker(495.0, 630.0, 'Sprout Tower', 'Crystal'),
      'heartgold': RegionMarker(495.0, 630.0, 'Sprout Tower', 'HeartGold'),
      'soulsilver': RegionMarker(495.0, 630.0, 'Sprout Tower', 'SoulSilver'),
      'default': RegionMarker(495.0, 630.0, 'Sprout Tower', 'Default'),
    },
    'union-cave': {
      'gold': RegionMarker(660.0, 645.0, 'Union Cave', 'Gold'),
      'silver': RegionMarker(660.0, 645.0, 'Union Cave', 'Silver'),
      'crystal': RegionMarker(660.0, 645.0, 'Union Cave', 'Crystal'),
      'heartgold': RegionMarker(660.0, 645.0, 'Union Cave', 'HeartGold'),
      'soulsilver': RegionMarker(660.0, 645.0, 'Union Cave', 'SoulSilver'),
      'default': RegionMarker(660.0, 645.0, 'Union Cave', 'Default'),
    },
    'slowpoke-well': {
      'gold': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'Gold'),
      'silver': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'Silver'),
      'crystal': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'Crystal'),
      'heartgold': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'HeartGold'),
      'soulsilver': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'SoulSilver'),
      'default': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'Default'),
    },
    'ilex-forest': {
      'gold': RegionMarker(765.0, 570.0, 'Ilex Forest', 'Gold'),
      'silver': RegionMarker(765.0, 570.0, 'Ilex Forest', 'Silver'),
      'crystal': RegionMarker(765.0, 570.0, 'Ilex Forest', 'Crystal'),
      'heartgold': RegionMarker(765.0, 570.0, 'Ilex Forest', 'HeartGold'),
      'soulsilver': RegionMarker(765.0, 570.0, 'Ilex Forest', 'SoulSilver'),
      'default': RegionMarker(765.0, 570.0, 'Ilex Forest', 'Default'),
    },
    'burned-tower': {
      'gold': RegionMarker(825.0, 510.0, 'Burned Tower', 'Gold'),
      'silver': RegionMarker(825.0, 510.0, 'Burned Tower', 'Silver'),
      'crystal': RegionMarker(825.0, 510.0, 'Burned Tower', 'Crystal'),
      'heartgold': RegionMarker(825.0, 510.0, 'Burned Tower', 'HeartGold'),
      'soulsilver': RegionMarker(825.0, 510.0, 'Burned Tower', 'SoulSilver'),
      'default': RegionMarker(825.0, 510.0, 'Burned Tower', 'Default'),
    },
    'bell-tower': {
      'gold': RegionMarker(855.0, 495.0, 'Bell Tower', 'Gold'),
      'silver': RegionMarker(855.0, 495.0, 'Bell Tower', 'Silver'),
      'crystal': RegionMarker(855.0, 495.0, 'Bell Tower', 'Crystal'),
      'heartgold': RegionMarker(855.0, 495.0, 'Bell Tower', 'HeartGold'),
      'soulsilver': RegionMarker(855.0, 495.0, 'Bell Tower', 'SoulSilver'),
      'default': RegionMarker(855.0, 495.0, 'Bell Tower', 'Default'),
    },
    'whirl-islands': {
      'gold': RegionMarker(525.0, 750.0, 'Whirl Islands', 'Gold'),
      'silver': RegionMarker(525.0, 750.0, 'Whirl Islands', 'Silver'),
      'crystal': RegionMarker(525.0, 750.0, 'Whirl Islands', 'Crystal'),
      'heartgold': RegionMarker(525.0, 750.0, 'Whirl Islands', 'HeartGold'),
      'soulsilver': RegionMarker(525.0, 750.0, 'Whirl Islands', 'SoulSilver'),
      'default': RegionMarker(525.0, 750.0, 'Whirl Islands', 'Default'),
    },
    'mt-mortar': {
      'gold': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'Gold'),
      'silver': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'Silver'),
      'crystal': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'Crystal'),
      'heartgold': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'HeartGold'),
      'soulsilver': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'SoulSilver'),
      'default': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'Default'),
    },
    'ice-path': {
      'gold': RegionMarker(900.0, 375.0, 'Ice Path', 'Gold'),
      'silver': RegionMarker(900.0, 375.0, 'Ice Path', 'Silver'),
      'crystal': RegionMarker(900.0, 375.0, 'Ice Path', 'Crystal'),
      'heartgold': RegionMarker(900.0, 375.0, 'Ice Path', 'HeartGold'),
      'soulsilver': RegionMarker(900.0, 375.0, 'Ice Path', 'SoulSilver'),
      'default': RegionMarker(900.0, 375.0, 'Ice Path', 'Default'),
    },
    'dragon-den': {
      'gold': RegionMarker(975.0, 420.0, "Dragon's Den", 'Gold'),
      'silver': RegionMarker(975.0, 420.0, "Dragon's Den", 'Silver'),
      'crystal': RegionMarker(975.0, 420.0, "Dragon's Den", 'Crystal'),
      'heartgold': RegionMarker(975.0, 420.0, "Dragon's Den", 'HeartGold'),
      'soulsilver': RegionMarker(975.0, 420.0, "Dragon's Den", 'SoulSilver'),
      'default': RegionMarker(975.0, 420.0, "Dragon's Den", 'Default'),
    },
  },
  'hoenn': {
    'route-101': {
      'ruby': RegionMarker(712.5, 880.0, 'Route 101', 'Ruby'),
      'sapphire': RegionMarker(712.5, 880.0, 'Route 101', 'Sapphire'),
      'emerald': RegionMarker(712.5, 880.0, 'Route 101', 'Emerald'),
      'omega-ruby': RegionMarker(712.5, 880.0, 'Route 101', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(712.5, 880.0, 'Route 101', 'Alpha Sapphire'),
      'default': RegionMarker(712.5, 880.0, 'Route 101', 'Default'),
    },
    'route-102': {
      'ruby': RegionMarker(656.2, 825.0, 'Route 102', 'Ruby'),
      'sapphire': RegionMarker(656.2, 825.0, 'Route 102', 'Sapphire'),
      'emerald': RegionMarker(656.2, 825.0, 'Route 102', 'Emerald'),
      'omega-ruby': RegionMarker(656.2, 825.0, 'Route 102', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(656.2, 825.0, 'Route 102', 'Alpha Sapphire'),
      'default': RegionMarker(656.2, 825.0, 'Route 102', 'Default'),
    },
    'route-103': {
      'ruby': RegionMarker(787.5, 806.7, 'Route 103', 'Ruby'),
      'sapphire': RegionMarker(787.5, 806.7, 'Route 103', 'Sapphire'),
      'emerald': RegionMarker(787.5, 806.7, 'Route 103', 'Emerald'),
      'omega-ruby': RegionMarker(787.5, 806.7, 'Route 103', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(787.5, 806.7, 'Route 103', 'Alpha Sapphire'),
      'default': RegionMarker(787.5, 806.7, 'Route 103', 'Default'),
    },
    'route-104': {
      'ruby': RegionMarker(600.0, 733.3, 'Route 104', 'Ruby'),
      'sapphire': RegionMarker(600.0, 733.3, 'Route 104', 'Sapphire'),
      'emerald': RegionMarker(600.0, 733.3, 'Route 104', 'Emerald'),
      'omega-ruby': RegionMarker(600.0, 733.3, 'Route 104', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(600.0, 733.3, 'Route 104', 'Alpha Sapphire'),
      'default': RegionMarker(600.0, 733.3, 'Route 104', 'Default'),
    },
    'route-110': {
      'ruby': RegionMarker(843.8, 696.7, 'Route 110', 'Ruby'),
      'sapphire': RegionMarker(843.8, 696.7, 'Route 110', 'Sapphire'),
      'emerald': RegionMarker(843.8, 696.7, 'Route 110', 'Emerald'),
      'omega-ruby': RegionMarker(843.8, 696.7, 'Route 110', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(843.8, 696.7, 'Route 110', 'Alpha Sapphire'),
      'default': RegionMarker(843.8, 696.7, 'Route 110', 'Default'),
    },
    'route-111': {
      'ruby': RegionMarker(937.5, 641.7, 'Route 111', 'Ruby'),
      'sapphire': RegionMarker(937.5, 641.7, 'Route 111', 'Sapphire'),
      'emerald': RegionMarker(937.5, 641.7, 'Route 111', 'Emerald'),
      'omega-ruby': RegionMarker(937.5, 641.7, 'Route 111', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(937.5, 641.7, 'Route 111', 'Alpha Sapphire'),
      'default': RegionMarker(937.5, 641.7, 'Route 111', 'Default'),
    },
    'route-119': {
      'ruby': RegionMarker(900.0, 513.3, 'Route 119', 'Ruby'),
      'sapphire': RegionMarker(900.0, 513.3, 'Route 119', 'Sapphire'),
      'emerald': RegionMarker(900.0, 513.3, 'Route 119', 'Emerald'),
      'omega-ruby': RegionMarker(900.0, 513.3, 'Route 119', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(900.0, 513.3, 'Route 119', 'Alpha Sapphire'),
      'default': RegionMarker(900.0, 513.3, 'Route 119', 'Default'),
    },
    'petalburg-woods': {
      'ruby': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Ruby'),
      'sapphire': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Sapphire'),
      'emerald': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Emerald'),
      'omega-ruby': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Alpha Sapphire'),
      'default': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Default'),
    },
    'meteor-falls': {
      'ruby': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Ruby'),
      'sapphire': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Sapphire'),
      'emerald': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Emerald'),
      'omega-ruby': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Alpha Sapphire'),
      'default': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Default'),
    },
    'granite-cave': {
      'ruby': RegionMarker(787.5, 733.3, 'Granite Cave', 'Ruby'),
      'sapphire': RegionMarker(787.5, 733.3, 'Granite Cave', 'Sapphire'),
      'emerald': RegionMarker(787.5, 733.3, 'Granite Cave', 'Emerald'),
      'omega-ruby': RegionMarker(787.5, 733.3, 'Granite Cave', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(787.5, 733.3, 'Granite Cave', 'Alpha Sapphire'),
      'default': RegionMarker(787.5, 733.3, 'Granite Cave', 'Default'),
    },
    'fiery-path': {
      'ruby': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Ruby'),
      'sapphire': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Sapphire'),
      'emerald': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Emerald'),
      'omega-ruby': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Alpha Sapphire'),
      'default': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Default'),
    },
    'jagged-pass': {
      'ruby': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Ruby'),
      'sapphire': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Sapphire'),
      'emerald': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Emerald'),
      'omega-ruby': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Alpha Sapphire'),
      'default': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Default'),
    },
    'mt-pyre': {
      'ruby': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Ruby'),
      'sapphire': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Sapphire'),
      'emerald': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Emerald'),
      'omega-ruby': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Alpha Sapphire'),
      'default': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Default'),
    },
    'seafloor-cavern': {
      'ruby': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Ruby'),
      'sapphire': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Sapphire'),
      'emerald': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Emerald'),
      'omega-ruby': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Alpha Sapphire'),
      'default': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Default'),
    },
    'cave-of-origin': {
      'ruby': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Ruby'),
      'sapphire': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Sapphire'),
      'emerald': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Emerald'),
      'omega-ruby': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Alpha Sapphire'),
      'default': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Default'),
    },
    'sky-pillar': {
      'ruby': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Ruby'),
      'sapphire': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Sapphire'),
      'emerald': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Emerald'),
      'omega-ruby': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Omega Ruby'),
      'alpha-sapphire': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Alpha Sapphire'),
      'default': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Default'),
    },
  },
  'sinnoh': {
    'route-201': {
      'diamond': RegionMarker(700.0, 750.0, 'Route 201', 'Diamond'),
      'pearl': RegionMarker(700.0, 750.0, 'Route 201', 'Pearl'),
      'platinum': RegionMarker(700.0, 750.0, 'Route 201', 'Platinum'),
      'brilliant-diamond': RegionMarker(700.0, 750.0, 'Route 201', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(700.0, 750.0, 'Route 201', 'Shining Pearl'),
      'default': RegionMarker(700.0, 750.0, 'Route 201', 'Default'),
    },
    'route-202': {
      'diamond': RegionMarker(735.0, 700.0, 'Route 202', 'Diamond'),
      'pearl': RegionMarker(735.0, 700.0, 'Route 202', 'Pearl'),
      'platinum': RegionMarker(735.0, 700.0, 'Route 202', 'Platinum'),
      'brilliant-diamond': RegionMarker(735.0, 700.0, 'Route 202', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(735.0, 700.0, 'Route 202', 'Shining Pearl'),
      'default': RegionMarker(735.0, 700.0, 'Route 202', 'Default'),
    },
    'route-203': {
      'diamond': RegionMarker(787.5, 666.7, 'Route 203', 'Diamond'),
      'pearl': RegionMarker(787.5, 666.7, 'Route 203', 'Pearl'),
      'platinum': RegionMarker(787.5, 666.7, 'Route 203', 'Platinum'),
      'brilliant-diamond': RegionMarker(787.5, 666.7, 'Route 203', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(787.5, 666.7, 'Route 203', 'Shining Pearl'),
      'default': RegionMarker(787.5, 666.7, 'Route 203', 'Default'),
    },
    'route-204': {
      'diamond': RegionMarker(665.0, 633.3, 'Route 204', 'Diamond'),
      'pearl': RegionMarker(665.0, 633.3, 'Route 204', 'Pearl'),
      'platinum': RegionMarker(665.0, 633.3, 'Route 204', 'Platinum'),
      'brilliant-diamond': RegionMarker(665.0, 633.3, 'Route 204', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(665.0, 633.3, 'Route 204', 'Shining Pearl'),
      'default': RegionMarker(665.0, 633.3, 'Route 204', 'Default'),
    },
    'route-205': {
      'diamond': RegionMarker(735.0, 583.3, 'Route 205', 'Diamond'),
      'pearl': RegionMarker(735.0, 583.3, 'Route 205', 'Pearl'),
      'platinum': RegionMarker(735.0, 583.3, 'Route 205', 'Platinum'),
      'brilliant-diamond': RegionMarker(735.0, 583.3, 'Route 205', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(735.0, 583.3, 'Route 205', 'Shining Pearl'),
      'default': RegionMarker(735.0, 583.3, 'Route 205', 'Default'),
    },
    'route-206': {
      'diamond': RegionMarker(700.0, 533.3, 'Route 206', 'Diamond'),
      'pearl': RegionMarker(700.0, 533.3, 'Route 206', 'Pearl'),
      'platinum': RegionMarker(700.0, 533.3, 'Route 206', 'Platinum'),
      'brilliant-diamond': RegionMarker(700.0, 533.3, 'Route 206', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(700.0, 533.3, 'Route 206', 'Shining Pearl'),
      'default': RegionMarker(700.0, 533.3, 'Route 206', 'Default'),
    },
    'eterna-forest': {
      'diamond': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Diamond'),
      'pearl': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Pearl'),
      'platinum': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Platinum'),
      'brilliant-diamond': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Shining Pearl'),
      'default': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Default'),
    },
    'oreburgh-gate': {
      'diamond': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Diamond'),
      'pearl': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Pearl'),
      'platinum': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Platinum'),
      'brilliant-diamond': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Shining Pearl'),
      'default': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Default'),
    },
    'oreburgh-mine': {
      'diamond': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Diamond'),
      'pearl': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Pearl'),
      'platinum': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Platinum'),
      'brilliant-diamond': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Shining Pearl'),
      'default': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Default'),
    },
    'ravaged-path': {
      'diamond': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Diamond'),
      'pearl': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Pearl'),
      'platinum': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Platinum'),
      'brilliant-diamond': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Shining Pearl'),
      'default': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Default'),
    },
    'wayward-cave': {
      'diamond': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Diamond'),
      'pearl': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Pearl'),
      'platinum': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Platinum'),
      'brilliant-diamond': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Shining Pearl'),
      'default': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Default'),
    },
    'mt-coronet': {
      'diamond': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Diamond'),
      'pearl': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Pearl'),
      'platinum': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Platinum'),
      'brilliant-diamond': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Shining Pearl'),
      'default': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Default'),
    },
    'iron-island': {
      'diamond': RegionMarker(437.5, 466.7, 'Iron Island', 'Diamond'),
      'pearl': RegionMarker(437.5, 466.7, 'Iron Island', 'Pearl'),
      'platinum': RegionMarker(437.5, 466.7, 'Iron Island', 'Platinum'),
      'brilliant-diamond': RegionMarker(437.5, 466.7, 'Iron Island', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(437.5, 466.7, 'Iron Island', 'Shining Pearl'),
      'default': RegionMarker(437.5, 466.7, 'Iron Island', 'Default'),
    },
    'old-chateau': {
      'diamond': RegionMarker(560.0, 566.7, 'Old Chateau', 'Diamond'),
      'pearl': RegionMarker(560.0, 566.7, 'Old Chateau', 'Pearl'),
      'platinum': RegionMarker(560.0, 566.7, 'Old Chateau', 'Platinum'),
      'brilliant-diamond': RegionMarker(560.0, 566.7, 'Old Chateau', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(560.0, 566.7, 'Old Chateau', 'Shining Pearl'),
      'default': RegionMarker(560.0, 566.7, 'Old Chateau', 'Default'),
    },
    'lake-verity': {
      'diamond': RegionMarker(665.0, 766.7, 'Lake Verity', 'Diamond'),
      'pearl': RegionMarker(665.0, 766.7, 'Lake Verity', 'Pearl'),
      'platinum': RegionMarker(665.0, 766.7, 'Lake Verity', 'Platinum'),
      'brilliant-diamond': RegionMarker(665.0, 766.7, 'Lake Verity', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(665.0, 766.7, 'Lake Verity', 'Shining Pearl'),
      'default': RegionMarker(665.0, 766.7, 'Lake Verity', 'Default'),
    },
    'lake-valor': {
      'diamond': RegionMarker(962.5, 633.3, 'Lake Valor', 'Diamond'),
      'pearl': RegionMarker(962.5, 633.3, 'Lake Valor', 'Pearl'),
      'platinum': RegionMarker(962.5, 633.3, 'Lake Valor', 'Platinum'),
      'brilliant-diamond': RegionMarker(962.5, 633.3, 'Lake Valor', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(962.5, 633.3, 'Lake Valor', 'Shining Pearl'),
      'default': RegionMarker(962.5, 633.3, 'Lake Valor', 'Default'),
    },
    'lake-acuity': {
      'diamond': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Diamond'),
      'pearl': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Pearl'),
      'platinum': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Platinum'),
      'brilliant-diamond': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Shining Pearl'),
      'default': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Default'),
    },
    'victory-road': {
      'diamond': RegionMarker(910.0, 416.7, 'Victory Road', 'Diamond'),
      'pearl': RegionMarker(910.0, 416.7, 'Victory Road', 'Pearl'),
      'platinum': RegionMarker(910.0, 416.7, 'Victory Road', 'Platinum'),
      'brilliant-diamond': RegionMarker(910.0, 416.7, 'Victory Road', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(910.0, 416.7, 'Victory Road', 'Shining Pearl'),
      'default': RegionMarker(910.0, 416.7, 'Victory Road', 'Default'),
    },
    'stark-mountain': {
      'diamond': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Diamond'),
      'pearl': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Pearl'),
      'platinum': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Platinum'),
      'brilliant-diamond': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Shining Pearl'),
      'default': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Default'),
    },
    'turnback-cave': {
      'diamond': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Diamond'),
      'pearl': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Pearl'),
      'platinum': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Platinum'),
      'brilliant-diamond': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Brilliant Diamond'),
      'shining-pearl': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Shining Pearl'),
      'default': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Default'),
    },
  },
  'unova': {
    'route-1': {
      'black': RegionMarker(800.0, 960.0, 'Route 1', 'Black'),
      'white': RegionMarker(800.0, 960.0, 'Route 1', 'White'),
      'black-2': RegionMarker(800.0, 960.0, 'Route 1', 'Black 2'),
      'white-2': RegionMarker(800.0, 960.0, 'Route 1', 'White 2'),
      'default': RegionMarker(800.0, 960.0, 'Route 1', 'Default'),
    },
    'route-2': {
      'black': RegionMarker(840.0, 900.0, 'Route 2', 'Black'),
      'white': RegionMarker(840.0, 900.0, 'Route 2', 'White'),
      'black-2': RegionMarker(840.0, 900.0, 'Route 2', 'Black 2'),
      'white-2': RegionMarker(840.0, 900.0, 'Route 2', 'White 2'),
      'default': RegionMarker(840.0, 900.0, 'Route 2', 'Default'),
    },
    'route-3': {
      'black': RegionMarker(960.0, 860.0, 'Route 3', 'Black'),
      'white': RegionMarker(960.0, 860.0, 'Route 3', 'White'),
      'black-2': RegionMarker(960.0, 860.0, 'Route 3', 'Black 2'),
      'white-2': RegionMarker(960.0, 860.0, 'Route 3', 'White 2'),
      'default': RegionMarker(960.0, 860.0, 'Route 3', 'Default'),
    },
    'route-4': {
      'black': RegionMarker(1080.0, 800.0, 'Route 4', 'Black'),
      'white': RegionMarker(1080.0, 800.0, 'Route 4', 'White'),
      'black-2': RegionMarker(1080.0, 800.0, 'Route 4', 'Black 2'),
      'white-2': RegionMarker(1080.0, 800.0, 'Route 4', 'White 2'),
      'default': RegionMarker(1080.0, 800.0, 'Route 4', 'Default'),
    },
    'dreamyard': {
      'black': RegionMarker(760.0, 920.0, 'Dreamyard', 'Black'),
      'white': RegionMarker(760.0, 920.0, 'Dreamyard', 'White'),
      'black-2': RegionMarker(760.0, 920.0, 'Dreamyard', 'Black 2'),
      'white-2': RegionMarker(760.0, 920.0, 'Dreamyard', 'White 2'),
      'default': RegionMarker(760.0, 920.0, 'Dreamyard', 'Default'),
    },
    'pinwheel-forest': {
      'black': RegionMarker(700.0, 840.0, 'Pinwheel Forest', 'Black'),
      'white': RegionMarker(700.0, 840.0, 'Pinwheel Forest', 'White'),
      'black-2': RegionMarker(700.0, 840.0, 'Pinwheel Forest', 'Black 2'),
      'white-2': RegionMarker(700.0, 840.0, 'Pinwheel Forest', 'White 2'),
      'default': RegionMarker(700.0, 840.0, 'Pinwheel Forest', 'Default'),
    },
    'desert-resort': {
      'black': RegionMarker(1120.0, 760.0, 'Desert Resort', 'Black'),
      'white': RegionMarker(1120.0, 760.0, 'Desert Resort', 'White'),
      'black-2': RegionMarker(1120.0, 760.0, 'Desert Resort', 'Black 2'),
      'white-2': RegionMarker(1120.0, 760.0, 'Desert Resort', 'White 2'),
      'default': RegionMarker(1120.0, 760.0, 'Desert Resort', 'Default'),
    },
    'relic-castle': {
      'black': RegionMarker(1160.0, 740.0, 'Relic Castle', 'Black'),
      'white': RegionMarker(1160.0, 740.0, 'Relic Castle', 'White'),
      'black-2': RegionMarker(1160.0, 740.0, 'Relic Castle', 'Black 2'),
      'white-2': RegionMarker(1160.0, 740.0, 'Relic Castle', 'White 2'),
      'default': RegionMarker(1160.0, 740.0, 'Relic Castle', 'Default'),
    },
    'chargestone-cave': {
      'black': RegionMarker(960.0, 700.0, 'Chargestone Cave', 'Black'),
      'white': RegionMarker(960.0, 700.0, 'Chargestone Cave', 'White'),
      'black-2': RegionMarker(960.0, 700.0, 'Chargestone Cave', 'Black 2'),
      'white-2': RegionMarker(960.0, 700.0, 'Chargestone Cave', 'White 2'),
      'default': RegionMarker(960.0, 700.0, 'Chargestone Cave', 'Default'),
    },
    'twist-mountain': {
      'black': RegionMarker(1040.0, 600.0, 'Twist Mountain', 'Black'),
      'white': RegionMarker(1040.0, 600.0, 'Twist Mountain', 'White'),
      'black-2': RegionMarker(1040.0, 600.0, 'Twist Mountain', 'Black 2'),
      'white-2': RegionMarker(1040.0, 600.0, 'Twist Mountain', 'White 2'),
      'default': RegionMarker(1040.0, 600.0, 'Twist Mountain', 'Default'),
    },
    'dragonspiral-tower': {
      'black': RegionMarker(1200.0, 560.0, 'Dragonspiral Tower', 'Black'),
      'white': RegionMarker(1200.0, 560.0, 'Dragonspiral Tower', 'White'),
      'black-2': RegionMarker(1200.0, 560.0, 'Dragonspiral Tower', 'Black 2'),
      'white-2': RegionMarker(1200.0, 560.0, 'Dragonspiral Tower', 'White 2'),
      'default': RegionMarker(1200.0, 560.0, 'Dragonspiral Tower', 'Default'),
    },
    'celestial-tower': {
      'black': RegionMarker(900.0, 640.0, 'Celestial Tower', 'Black'),
      'white': RegionMarker(900.0, 640.0, 'Celestial Tower', 'White'),
      'black-2': RegionMarker(900.0, 640.0, 'Celestial Tower', 'Black 2'),
      'white-2': RegionMarker(900.0, 640.0, 'Celestial Tower', 'White 2'),
      'default': RegionMarker(900.0, 640.0, 'Celestial Tower', 'Default'),
    },
    'victory-road': {
      'black': RegionMarker(1300.0, 440.0, 'Victory Road', 'Black'),
      'white': RegionMarker(1300.0, 440.0, 'Victory Road', 'White'),
      'black-2': RegionMarker(1300.0, 440.0, 'Victory Road', 'Black 2'),
      'white-2': RegionMarker(1300.0, 440.0, 'Victory Road', 'White 2'),
      'default': RegionMarker(1300.0, 440.0, 'Victory Road', 'Default'),
    },
    'giants-chasm': {
      'black': RegionMarker(1360.0, 400.0, "Giant's Chasm", 'Black'),
      'white': RegionMarker(1360.0, 400.0, "Giant's Chasm", 'White'),
      'black-2': RegionMarker(1360.0, 400.0, "Giant's Chasm", 'Black 2'),
      'white-2': RegionMarker(1360.0, 400.0, "Giant's Chasm", 'White 2'),
      'default': RegionMarker(1360.0, 400.0, "Giant's Chasm", 'Default'),
    },
  },
  'kalos': {
    'route-1': {
      'x': RegionMarker(900.0, 1120.0, 'Route 1', 'X'),
      'y': RegionMarker(900.0, 1120.0, 'Route 1', 'Y'),
      'default': RegionMarker(900.0, 1120.0, 'Route 1', 'Default'),
    },
    'route-2': {
      'x': RegionMarker(855.0, 1050.0, 'Route 2', 'X'),
      'y': RegionMarker(855.0, 1050.0, 'Route 2', 'Y'),
      'default': RegionMarker(855.0, 1050.0, 'Route 2', 'Default'),
    },
    'route-3': {
      'x': RegionMarker(945.0, 980.0, 'Route 3', 'X'),
      'y': RegionMarker(945.0, 980.0, 'Route 3', 'Y'),
      'default': RegionMarker(945.0, 980.0, 'Route 3', 'Default'),
    },
    'santalune-forest': {
      'x': RegionMarker(810.0, 1073.3, 'Santalune Forest', 'X'),
      'y': RegionMarker(810.0, 1073.3, 'Santalune Forest', 'Y'),
      'default': RegionMarker(810.0, 1073.3, 'Santalune Forest', 'Default'),
    },
    'connecting-cave': {
      'x': RegionMarker(1012.5, 933.3, 'Connecting Cave', 'X'),
      'y': RegionMarker(1012.5, 933.3, 'Connecting Cave', 'Y'),
      'default': RegionMarker(1012.5, 933.3, 'Connecting Cave', 'Default'),
    },
    'glittering-cave': {
      'x': RegionMarker(1080.0, 886.7, 'Glittering Cave', 'X'),
      'y': RegionMarker(1080.0, 886.7, 'Glittering Cave', 'Y'),
      'default': RegionMarker(1080.0, 886.7, 'Glittering Cave', 'Default'),
    },
    'reflection-cave': {
      'x': RegionMarker(1170.0, 816.7, 'Reflection Cave', 'X'),
      'y': RegionMarker(1170.0, 816.7, 'Reflection Cave', 'Y'),
      'default': RegionMarker(1170.0, 816.7, 'Reflection Cave', 'Default'),
    },
    'frost-cavern': {
      'x': RegionMarker(1237.5, 700.0, 'Frost Cavern', 'X'),
      'y': RegionMarker(1237.5, 700.0, 'Frost Cavern', 'Y'),
      'default': RegionMarker(1237.5, 700.0, 'Frost Cavern', 'Default'),
    },
    'pokemon-village': {
      'x': RegionMarker(1305.0, 583.3, 'Pokemon Village', 'X'),
      'y': RegionMarker(1305.0, 583.3, 'Pokemon Village', 'Y'),
      'default': RegionMarker(1305.0, 583.3, 'Pokemon Village', 'Default'),
    },
    'victory-road': {
      'x': RegionMarker(1395.0, 513.3, 'Victory Road', 'X'),
      'y': RegionMarker(1395.0, 513.3, 'Victory Road', 'Y'),
      'default': RegionMarker(1395.0, 513.3, 'Victory Road', 'Default'),
    },
    'terminus-cave': {
      'x': RegionMarker(1125.0, 746.7, 'Terminus Cave', 'X'),
      'y': RegionMarker(1125.0, 746.7, 'Terminus Cave', 'Y'),
      'default': RegionMarker(1125.0, 746.7, 'Terminus Cave', 'Default'),
    },
  },
  'alola': {
    'route-1': {
      'sun': RegionMarker(840.0, 700.0, 'Route 1', 'Sun'),
      'moon': RegionMarker(840.0, 700.0, 'Route 1', 'Moon'),
      'ultra-sun': RegionMarker(840.0, 700.0, 'Route 1', 'Ultra Sun'),
      'ultra-moon': RegionMarker(840.0, 700.0, 'Route 1', 'Ultra Moon'),
      'default': RegionMarker(840.0, 700.0, 'Route 1', 'Default'),
    },
    'route-2': {
      'sun': RegionMarker(760.0, 640.0, 'Route 2', 'Sun'),
      'moon': RegionMarker(760.0, 640.0, 'Route 2', 'Moon'),
      'ultra-sun': RegionMarker(760.0, 640.0, 'Route 2', 'Ultra Sun'),
      'ultra-moon': RegionMarker(760.0, 640.0, 'Route 2', 'Ultra Moon'),
      'default': RegionMarker(760.0, 640.0, 'Route 2', 'Default'),
    },
    'route-3': {
      'sun': RegionMarker(900.0, 600.0, 'Route 3', 'Sun'),
      'moon': RegionMarker(900.0, 600.0, 'Route 3', 'Moon'),
      'ultra-sun': RegionMarker(900.0, 600.0, 'Route 3', 'Ultra Sun'),
      'ultra-moon': RegionMarker(900.0, 600.0, 'Route 3', 'Ultra Moon'),
      'default': RegionMarker(900.0, 600.0, 'Route 3', 'Default'),
    },
    'melemele-meadow': {
      'sun': RegionMarker(800.0, 760.0, 'Melemele Meadow', 'Sun'),
      'moon': RegionMarker(800.0, 760.0, 'Melemele Meadow', 'Moon'),
      'ultra-sun': RegionMarker(800.0, 760.0, 'Melemele Meadow', 'Ultra Sun'),
      'ultra-moon': RegionMarker(800.0, 760.0, 'Melemele Meadow', 'Ultra Moon'),
      'default': RegionMarker(800.0, 760.0, 'Melemele Meadow', 'Default'),
    },
    'verdant-cavern': {
      'sun': RegionMarker(860.0, 680.0, 'Verdant Cavern', 'Sun'),
      'moon': RegionMarker(860.0, 680.0, 'Verdant Cavern', 'Moon'),
      'ultra-sun': RegionMarker(860.0, 680.0, 'Verdant Cavern', 'Ultra Sun'),
      'ultra-moon': RegionMarker(860.0, 680.0, 'Verdant Cavern', 'Ultra Moon'),
      'default': RegionMarker(860.0, 680.0, 'Verdant Cavern', 'Default'),
    },
    'seaward-cave': {
      'sun': RegionMarker(720.0, 720.0, 'Seaward Cave', 'Sun'),
      'moon': RegionMarker(720.0, 720.0, 'Seaward Cave', 'Moon'),
      'ultra-sun': RegionMarker(720.0, 720.0, 'Seaward Cave', 'Ultra Sun'),
      'ultra-moon': RegionMarker(720.0, 720.0, 'Seaward Cave', 'Ultra Moon'),
      'default': RegionMarker(720.0, 720.0, 'Seaward Cave', 'Default'),
    },
    'ten-carat-hill': {
      'sun': RegionMarker(880.0, 740.0, 'Ten Carat Hill', 'Sun'),
      'moon': RegionMarker(880.0, 740.0, 'Ten Carat Hill', 'Moon'),
      'ultra-sun': RegionMarker(880.0, 740.0, 'Ten Carat Hill', 'Ultra Sun'),
      'ultra-moon': RegionMarker(880.0, 740.0, 'Ten Carat Hill', 'Ultra Moon'),
      'default': RegionMarker(880.0, 740.0, 'Ten Carat Hill', 'Default'),
    },
    'brooklet-hill': {
      'sun': RegionMarker(600.0, 560.0, 'Brooklet Hill', 'Sun'),
      'moon': RegionMarker(600.0, 560.0, 'Brooklet Hill', 'Moon'),
      'ultra-sun': RegionMarker(600.0, 560.0, 'Brooklet Hill', 'Ultra Sun'),
      'ultra-moon': RegionMarker(600.0, 560.0, 'Brooklet Hill', 'Ultra Moon'),
      'default': RegionMarker(600.0, 560.0, 'Brooklet Hill', 'Default'),
    },
    'wela-volcano-park': {
      'sun': RegionMarker(1000.0, 640.0, 'Wela Volcano Park', 'Sun'),
      'moon': RegionMarker(1000.0, 640.0, 'Wela Volcano Park', 'Moon'),
      'ultra-sun': RegionMarker(1000.0, 640.0, 'Wela Volcano Park', 'Ultra Sun'),
      'ultra-moon': RegionMarker(1000.0, 640.0, 'Wela Volcano Park', 'Ultra Moon'),
      'default': RegionMarker(1000.0, 640.0, 'Wela Volcano Park', 'Default'),
    },
    'lush-jungle': {
      'sun': RegionMarker(700.0, 500.0, 'Lush Jungle', 'Sun'),
      'moon': RegionMarker(700.0, 500.0, 'Lush Jungle', 'Moon'),
      'ultra-sun': RegionMarker(700.0, 500.0, 'Lush Jungle', 'Ultra Sun'),
      'ultra-moon': RegionMarker(700.0, 500.0, 'Lush Jungle', 'Ultra Moon'),
      'default': RegionMarker(700.0, 500.0, 'Lush Jungle', 'Default'),
    },
    'mount-lanakila': {
      'sun': RegionMarker(800.0, 400.0, 'Mount Lanakila', 'Sun'),
      'moon': RegionMarker(800.0, 400.0, 'Mount Lanakila', 'Moon'),
      'ultra-sun': RegionMarker(800.0, 400.0, 'Mount Lanakila', 'Ultra Sun'),
      'ultra-moon': RegionMarker(800.0, 400.0, 'Mount Lanakila', 'Ultra Moon'),
      'default': RegionMarker(800.0, 400.0, 'Mount Lanakila', 'Default'),
    },
    'vast-poni-canyon': {
      'sun': RegionMarker(1200.0, 760.0, 'Vast Poni Canyon', 'Sun'),
      'moon': RegionMarker(1200.0, 760.0, 'Vast Poni Canyon', 'Moon'),
      'ultra-sun': RegionMarker(1200.0, 760.0, 'Vast Poni Canyon', 'Ultra Sun'),
      'ultra-moon': RegionMarker(1200.0, 760.0, 'Vast Poni Canyon', 'Ultra Moon'),
      'default': RegionMarker(1200.0, 760.0, 'Vast Poni Canyon', 'Default'),
    },
  },
  'galar': {
    'route-1': {
      'sword': RegionMarker(1000.0, 1200.0, 'Route 1', 'Sword'),
      'shield': RegionMarker(1000.0, 1200.0, 'Route 1', 'Shield'),
      'default': RegionMarker(1000.0, 1200.0, 'Route 1', 'Default'),
    },
    'route-2': {
      'sword': RegionMarker(1050.0, 1125.0, 'Route 2', 'Sword'),
      'shield': RegionMarker(1050.0, 1125.0, 'Route 2', 'Shield'),
      'default': RegionMarker(1050.0, 1125.0, 'Route 2', 'Default'),
    },
    'route-3': {
      'sword': RegionMarker(950.0, 1050.0, 'Route 3', 'Sword'),
      'shield': RegionMarker(950.0, 1050.0, 'Route 3', 'Shield'),
      'default': RegionMarker(950.0, 1050.0, 'Route 3', 'Default'),
    },
    'galar-mine': {
      'sword': RegionMarker(1100.0, 1000.0, 'Galar Mine', 'Sword'),
      'shield': RegionMarker(1100.0, 1000.0, 'Galar Mine', 'Shield'),
      'default': RegionMarker(1100.0, 1000.0, 'Galar Mine', 'Default'),
    },
    'galar-mine-no-2': {
      'sword': RegionMarker(1150.0, 950.0, 'Galar Mine No. 2', 'Sword'),
      'shield': RegionMarker(1150.0, 950.0, 'Galar Mine No. 2', 'Shield'),
      'default': RegionMarker(1150.0, 950.0, 'Galar Mine No. 2', 'Default'),
    },
    'rolling-fields': {
      'sword': RegionMarker(875.0, 1000.0, 'Rolling Fields', 'Sword'),
      'shield': RegionMarker(875.0, 1000.0, 'Rolling Fields', 'Shield'),
      'default': RegionMarker(875.0, 1000.0, 'Rolling Fields', 'Default'),
    },
    'dappled-grove': {
      'sword': RegionMarker(925.0, 950.0, 'Dappled Grove', 'Sword'),
      'shield': RegionMarker(925.0, 950.0, 'Dappled Grove', 'Shield'),
      'default': RegionMarker(925.0, 950.0, 'Dappled Grove', 'Default'),
    },
    'watchtower-ruins': {
      'sword': RegionMarker(1000.0, 900.0, 'Watchtower Ruins', 'Sword'),
      'shield': RegionMarker(1000.0, 900.0, 'Watchtower Ruins', 'Shield'),
      'default': RegionMarker(1000.0, 900.0, 'Watchtower Ruins', 'Default'),
    },
    'motostoke-riverbank': {
      'sword': RegionMarker(1200.0, 1050.0, 'Motostoke Riverbank', 'Sword'),
      'shield': RegionMarker(1200.0, 1050.0, 'Motostoke Riverbank', 'Shield'),
      'default': RegionMarker(1200.0, 1050.0, 'Motostoke Riverbank', 'Default'),
    },
    'dusty-bowl': {
      'sword': RegionMarker(1250.0, 850.0, 'Dusty Bowl', 'Sword'),
      'shield': RegionMarker(1250.0, 850.0, 'Dusty Bowl', 'Shield'),
      'default': RegionMarker(1250.0, 850.0, 'Dusty Bowl', 'Default'),
    },
    'giant-mirror': {
      'sword': RegionMarker(1300.0, 800.0, "Giant's Mirror", 'Sword'),
      'shield': RegionMarker(1300.0, 800.0, "Giant's Mirror", 'Shield'),
      'default': RegionMarker(1300.0, 800.0, "Giant's Mirror", 'Default'),
    },
    'hammerlocke-hills': {
      'sword': RegionMarker(1350.0, 750.0, 'Hammerlocke Hills', 'Sword'),
      'shield': RegionMarker(1350.0, 750.0, 'Hammerlocke Hills', 'Shield'),
      'default': RegionMarker(1350.0, 750.0, 'Hammerlocke Hills', 'Default'),
    },
    'slumbering-weald': {
      'sword': RegionMarker(1050.0, 1150.0, 'Slumbering Weald', 'Sword'),
      'shield': RegionMarker(1050.0, 1150.0, 'Slumbering Weald', 'Shield'),
      'default': RegionMarker(1050.0, 1150.0, 'Slumbering Weald', 'Default'),
    },
    'glimwood-tangle': {
      'sword': RegionMarker(1200.0, 700.0, 'Glimwood Tangle', 'Sword'),
      'shield': RegionMarker(1200.0, 700.0, 'Glimwood Tangle', 'Shield'),
      'default': RegionMarker(1200.0, 700.0, 'Glimwood Tangle', 'Default'),
    },
    'ballonlea': {
      'sword': RegionMarker(1000.0, 750.0, 'Ballonlea', 'Sword'),
      'shield': RegionMarker(1000.0, 750.0, 'Ballonlea', 'Shield'),
      'default': RegionMarker(1000.0, 750.0, 'Ballonlea', 'Default'),
    },
  },
};

/// Obtiene el marcador para un área específica en una región
///
/// Si se especifica [gameVersion], se buscará primero una coincidencia exacta
/// (normalizada) y luego se realizará un fallback a la entrada `default`.
RegionMarker? getRegionMarker(
  String regionName,
  String areaName, {
  String? gameVersion,
}) {
  final normalizedRegion = regionName.toLowerCase().trim();
  final region = regionMarkersByRegion[normalizedRegion];

  if (region == null) return null;

  final areaKey = _normalizeAreaName(areaName);
  final areaMarkers = region[areaKey];

  if (areaMarkers == null) return null;

  final normalizedVersion = gameVersion != null
      ? _normalizeVersionName(gameVersion)
      : null;

  if (normalizedVersion != null) {
    final directMatch = _findMarkerByVersion(areaMarkers, normalizedVersion);
    if (directMatch != null) return directMatch;
  }

  // Fallback al marcador por defecto si existe, o la primera entrada conocida
  return areaMarkers['default'] ?? areaMarkers.values.first;
}

RegionMarker? _findMarkerByVersion(
  VersionedMarkers markers,
  String normalizedVersion,
) {
  for (final entry in markers.entries) {
    final key = _normalizeVersionName(entry.key);
    if (key == normalizedVersion || key.contains(normalizedVersion) ||
        normalizedVersion.contains(key)) {
      return entry.value;
    }
  }
  return null;
}

/// Normaliza el nombre de un área para buscar en el mapa
String _normalizeAreaName(String areaName) {
  return areaName
      .toLowerCase()
      .trim()
      .replaceAll('-area', '')
      .replaceAll('_area', '')
      .replaceAll(' area', '');
}

String _normalizeVersionName(String version) {
  return version
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
      .trim();
}

/// Obtiene todos los marcadores disponibles para una región
Map<String, RegionMarker>? getRegionMarkers(
  String regionName, {
  String? gameVersion,
}) {
  final normalized = regionName.toLowerCase().trim();
  final region = regionMarkersByRegion[normalized];
  if (region == null) return null;

  final Map<String, RegionMarker> result = {};
  for (final entry in region.entries) {
    final marker = getRegionMarker(regionName, entry.key, gameVersion: gameVersion);
    if (marker != null) {
      result[entry.key] = marker;
    }
  }
  return result;
}

/// Verifica si una región tiene marcadores disponibles
bool hasRegionMarkers(String regionName) {
  return getRegionMarkers(regionName)?.isNotEmpty ?? false;
}

/// Obtiene todas las regiones con marcadores disponibles
List<String> getAvailableRegionsWithMarkers() {
  return regionMarkersByRegion.keys.toList();
}

/// Obtiene una posición por defecto para una región (centro del mapa)
RegionMarker getDefaultRegionMarker(String regionName) {
  return RegionMarker(400, 300, regionName, 'Default');
}
