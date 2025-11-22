/// Coordenadas X/Y para marcadores en los mapas de regiones Pokémon
///
/// Las coordenadas son relativas a las dimensiones reales de cada mapa.
/// Ajusta estas coordenadas según las imágenes oficiales que subas.

/// Clase para representar un marcador en el mapa de región
class RegionMarker {
  const RegionMarker(this.x, this.y, this.area, this.game);

  /// Posición X en píxeles sobre la imagen del mapa
  final double x;

  /// Posición Y en píxeles sobre la imagen del mapa
  final double y;

  /// Nombre del área (ej: "Route 1", "Viridian Forest")
  final String area;

  /// Versión del juego donde aparece (ej: "FireRed/LeafGreen", "FRLG")
  final String game;
}

/// Mapa de marcadores por región
///
/// Cada región tiene un diccionario de ubicaciones con sus coordenadas X/Y.
/// Las claves son los nombres de las áreas normalizadas (ej: "route-1", "viridian-forest").
const Map<String, Map<String, RegionMarker>> regionMarkers = {
  'kanto': {
    'route-1': RegionMarker(512.0, 576.0, 'Route 1', 'FireRed/LeafGreen'),
    'route-2': RegionMarker(448.0, 486.4, 'Route 2', 'FRLG'),
    'route-3': RegionMarker(640.0, 448.0, 'Route 3', 'FRLG'),
    'route-4': RegionMarker(704.0, 384.0, 'Route 4', 'FRLG'),
    'route-5': RegionMarker(576.0, 320.0, 'Route 5', 'FRLG'),
    'route-6': RegionMarker(512.0, 448.0, 'Route 6', 'FRLG'),
    'viridian-forest': RegionMarker(448.0, 512.0, 'Viridian Forest', 'FRLG'),
    'mt-moon': RegionMarker(614.4, 448.0, 'Mt. Moon', 'FRLG'),
    'rock-tunnel': RegionMarker(704.0, 358.4, 'Rock Tunnel', 'FRLG'),
    'pokemon-tower': RegionMarker(768.0, 409.6, 'Pokemon Tower', 'FRLG'),
    'seafoam-islands': RegionMarker(384.0, 614.4, 'Seafoam Islands', 'FRLG'),
    'victory-road': RegionMarker(256.0, 256.0, 'Victory Road', 'FRLG'),
    'cerulean-cave': RegionMarker(576.0, 256.0, 'Cerulean Cave', 'FRLG'),
  },
  'johto': {
    'route-29': RegionMarker(450.0, 675.0, 'Route 29', 'HeartGold/SoulSilver'),
    'route-30': RegionMarker(480.0, 600.0, 'Route 30', 'HGSS'),
    'route-31': RegionMarker(570.0, 570.0, 'Route 31', 'HGSS'),
    'route-32': RegionMarker(675.0, 630.0, 'Route 32', 'HGSS'),
    'route-33': RegionMarker(780.0, 600.0, 'Route 33', 'HGSS'),
    'route-34': RegionMarker(720.0, 525.0, 'Route 34', 'HGSS'),
    'sprout-tower': RegionMarker(495.0, 630.0, 'Sprout Tower', 'HGSS'),
    'union-cave': RegionMarker(660.0, 645.0, 'Union Cave', 'HGSS'),
    'slowpoke-well': RegionMarker(735.0, 540.0, 'Slowpoke Well', 'HGSS'),
    'ilex-forest': RegionMarker(765.0, 570.0, 'Ilex Forest', 'HGSS'),
    'burned-tower': RegionMarker(825.0, 510.0, 'Burned Tower', 'HGSS'),
    'bell-tower': RegionMarker(855.0, 495.0, 'Bell Tower', 'HGSS'),
    'whirl-islands': RegionMarker(525.0, 750.0, 'Whirl Islands', 'HGSS'),
    'mt-mortar': RegionMarker(720.0, 450.0, 'Mt. Mortar', 'HGSS'),
    'ice-path': RegionMarker(900.0, 375.0, 'Ice Path', 'HGSS'),
    'dragon-den': RegionMarker(975.0, 420.0, 'Dragon\'s Den', 'HGSS'),
  },
  'hoenn': {
    'route-101': RegionMarker(712.5, 880.0, 'Route 101', 'Emerald'),
    'route-102': RegionMarker(656.2, 825.0, 'Route 102', 'Emerald'),
    'route-103': RegionMarker(787.5, 806.7, 'Route 103', 'Emerald'),
    'route-104': RegionMarker(600.0, 733.3, 'Route 104', 'Emerald'),
    'route-110': RegionMarker(843.8, 696.7, 'Route 110', 'Emerald'),
    'route-111': RegionMarker(937.5, 641.7, 'Route 111', 'Emerald'),
    'route-119': RegionMarker(900.0, 513.3, 'Route 119', 'Emerald'),
    'petalburg-woods': RegionMarker(562.5, 770.0, 'Petalburg Woods', 'Emerald'),
    'meteor-falls': RegionMarker(975.0, 586.7, 'Meteor Falls', 'Emerald'),
    'granite-cave': RegionMarker(787.5, 733.3, 'Granite Cave', 'Emerald'),
    'fiery-path': RegionMarker(1012.5, 623.3, 'Fiery Path', 'Emerald'),
    'jagged-pass': RegionMarker(1050.0, 568.3, 'Jagged Pass', 'Emerald'),
    'mt-pyre': RegionMarker(1125.0, 641.7, 'Mt. Pyre', 'Emerald'),
    'seafloor-cavern': RegionMarker(1218.8, 770.0, 'Seafloor Cavern', 'Emerald'),
    'cave-of-origin': RegionMarker(1162.5, 550.0, 'Cave of Origin', 'Emerald'),
    'sky-pillar': RegionMarker(1312.5, 458.3, 'Sky Pillar', 'Emerald'),
  },
  'sinnoh': {
    'route-201': RegionMarker(700.0, 750.0, 'Route 201', 'Platinum'),
    'route-202': RegionMarker(735.0, 700.0, 'Route 202', 'Platinum'),
    'route-203': RegionMarker(787.5, 666.7, 'Route 203', 'Platinum'),
    'route-204': RegionMarker(665.0, 633.3, 'Route 204', 'Platinum'),
    'route-205': RegionMarker(735.0, 583.3, 'Route 205', 'Platinum'),
    'route-206': RegionMarker(700.0, 533.3, 'Route 206', 'Platinum'),
    'eterna-forest': RegionMarker(612.5, 600.0, 'Eterna Forest', 'Platinum'),
    'oreburgh-gate': RegionMarker(840.0, 716.7, 'Oreburgh Gate', 'Platinum'),
    'oreburgh-mine': RegionMarker(875.0, 733.3, 'Oreburgh Mine', 'Platinum'),
    'ravaged-path': RegionMarker(630.0, 650.0, 'Ravaged Path', 'Platinum'),
    'wayward-cave': RegionMarker(735.0, 516.7, 'Wayward Cave', 'Platinum'),
    'mt-coronet': RegionMarker(840.0, 533.3, 'Mt. Coronet', 'Platinum'),
    'iron-island': RegionMarker(437.5, 466.7, 'Iron Island', 'Platinum'),
    'old-chateau': RegionMarker(560.0, 566.7, 'Old Chateau', 'Platinum'),
    'lake-verity': RegionMarker(665.0, 766.7, 'Lake Verity', 'Platinum'),
    'lake-valor': RegionMarker(962.5, 633.3, 'Lake Valor', 'Platinum'),
    'lake-acuity': RegionMarker(1050.0, 333.3, 'Lake Acuity', 'Platinum'),
    'victory-road': RegionMarker(910.0, 416.7, 'Victory Road', 'Platinum'),
    'stark-mountain': RegionMarker(1137.5, 533.3, 'Stark Mountain', 'Platinum'),
    'turnback-cave': RegionMarker(1225.0, 466.7, 'Turnback Cave', 'Platinum'),
  },
  'unova': {
    'route-1': RegionMarker(800.0, 960.0, 'Route 1', 'Black/White'),
    'route-2': RegionMarker(840.0, 900.0, 'Route 2', 'BW'),
    'route-3': RegionMarker(960.0, 860.0, 'Route 3', 'BW'),
    'route-4': RegionMarker(1080.0, 800.0, 'Route 4', 'BW'),
    'dreamyard': RegionMarker(760.0, 920.0, 'Dreamyard', 'BW'),
    'pinwheel-forest': RegionMarker(700.0, 840.0, 'Pinwheel Forest', 'BW'),
    'desert-resort': RegionMarker(1120.0, 760.0, 'Desert Resort', 'BW'),
    'relic-castle': RegionMarker(1160.0, 740.0, 'Relic Castle', 'BW'),
    'chargestone-cave': RegionMarker(960.0, 700.0, 'Chargestone Cave', 'BW'),
    'twist-mountain': RegionMarker(1040.0, 600.0, 'Twist Mountain', 'BW'),
    'dragonspiral-tower': RegionMarker(1200.0, 560.0, 'Dragonspiral Tower', 'BW'),
    'celestial-tower': RegionMarker(900.0, 640.0, 'Celestial Tower', 'BW'),
    'victory-road': RegionMarker(1300.0, 440.0, 'Victory Road', 'BW'),
    'giants-chasm': RegionMarker(1360.0, 400.0, 'Giant\'s Chasm', 'BW'),
  },
  'kalos': {
    'route-1': RegionMarker(900.0, 1120.0, 'Route 1', 'X/Y'),
    'route-2': RegionMarker(855.0, 1050.0, 'Route 2', 'X/Y'),
    'route-3': RegionMarker(945.0, 980.0, 'Route 3', 'X/Y'),
    'santalune-forest': RegionMarker(810.0, 1073.3, 'Santalune Forest', 'X/Y'),
    'connecting-cave': RegionMarker(1012.5, 933.3, 'Connecting Cave', 'X/Y'),
    'glittering-cave': RegionMarker(1080.0, 886.7, 'Glittering Cave', 'X/Y'),
    'reflection-cave': RegionMarker(1170.0, 816.7, 'Reflection Cave', 'X/Y'),
    'frost-cavern': RegionMarker(1237.5, 700.0, 'Frost Cavern', 'X/Y'),
    'pokemon-village': RegionMarker(1305.0, 583.3, 'Pokemon Village', 'X/Y'),
    'victory-road': RegionMarker(1395.0, 513.3, 'Victory Road', 'X/Y'),
    'terminus-cave': RegionMarker(1125.0, 746.7, 'Terminus Cave', 'X/Y'),
  },
  'alola': {
    'route-1': RegionMarker(840.0, 700.0, 'Route 1', 'Sun/Moon'),
    'route-2': RegionMarker(760.0, 640.0, 'Route 2', 'SM'),
    'route-3': RegionMarker(900.0, 600.0, 'Route 3', 'SM'),
    'melemele-meadow': RegionMarker(800.0, 760.0, 'Melemele Meadow', 'SM'),
    'verdant-cavern': RegionMarker(860.0, 680.0, 'Verdant Cavern', 'SM'),
    'seaward-cave': RegionMarker(720.0, 720.0, 'Seaward Cave', 'SM'),
    'ten-carat-hill': RegionMarker(880.0, 740.0, 'Ten Carat Hill', 'SM'),
    'brooklet-hill': RegionMarker(600.0, 560.0, 'Brooklet Hill', 'SM'),
    'wela-volcano-park': RegionMarker(1000.0, 640.0, 'Wela Volcano Park', 'SM'),
    'lush-jungle': RegionMarker(700.0, 500.0, 'Lush Jungle', 'SM'),
    'mount-lanakila': RegionMarker(800.0, 400.0, 'Mount Lanakila', 'SM'),
    'vast-poni-canyon': RegionMarker(1200.0, 760.0, 'Vast Poni Canyon', 'SM'),
  },
  'galar': {
    'route-1': RegionMarker(1000.0, 1200.0, 'Route 1', 'Sword/Shield'),
    'route-2': RegionMarker(1050.0, 1125.0, 'Route 2', 'SwSh'),
    'route-3': RegionMarker(950.0, 1050.0, 'Route 3', 'SwSh'),
    'galar-mine': RegionMarker(1100.0, 1000.0, 'Galar Mine', 'SwSh'),
    'galar-mine-no-2': RegionMarker(1150.0, 950.0, 'Galar Mine No. 2', 'SwSh'),
    'rolling-fields': RegionMarker(875.0, 1000.0, 'Rolling Fields', 'SwSh'),
    'dappled-grove': RegionMarker(925.0, 950.0, 'Dappled Grove', 'SwSh'),
    'watchtower-ruins': RegionMarker(1000.0, 900.0, 'Watchtower Ruins', 'SwSh'),
    'motostoke-riverbank': RegionMarker(1200.0, 1050.0, 'Motostoke Riverbank', 'SwSh'),
    'dusty-bowl': RegionMarker(1250.0, 850.0, 'Dusty Bowl', 'SwSh'),
    'giant-mirror': RegionMarker(1300.0, 800.0, 'Giant\'s Mirror', 'SwSh'),
    'hammerlocke-hills': RegionMarker(1350.0, 750.0, 'Hammerlocke Hills', 'SwSh'),
    'slumbering-weald': RegionMarker(1050.0, 1150.0, 'Slumbering Weald', 'SwSh'),
    'glimwood-tangle': RegionMarker(1200.0, 700.0, 'Glimwood Tangle', 'SwSh'),
    'ballonlea': RegionMarker(1000.0, 750.0, 'Ballonlea', 'SwSh'),
  },
};

/// Obtiene el marcador para un área específica en una región
///
/// Retorna null si la región o el área no están mapeadas
RegionMarker? getRegionMarker(String regionName, String areaName) {
  final normalized = regionName.toLowerCase().trim();
  final region = regionMarkers[normalized];
  
  if (region == null) return null;
  
  // Normalizar el nombre del área (remover sufijos comunes)
  final areaKey = _normalizeAreaName(areaName);
  
  return region[areaKey];
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

/// Obtiene todos los marcadores disponibles para una región
Map<String, RegionMarker>? getRegionMarkers(String regionName) {
  final normalized = regionName.toLowerCase().trim();
  return regionMarkers[normalized];
}

/// Verifica si una región tiene marcadores disponibles
bool hasRegionMarkers(String regionName) {
  return getRegionMarkers(regionName) != null;
}

/// Obtiene todas las regiones con marcadores disponibles
List<String> getAvailableRegionsWithMarkers() {
  return regionMarkers.keys.toList();
}

/// Obtiene una posición por defecto para una región (centro del mapa)
RegionMarker getDefaultRegionMarker(String regionName) {
  return RegionMarker(400, 300, regionName, 'Default');
}
