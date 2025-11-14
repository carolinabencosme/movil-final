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
    'route-1': RegionMarker(400, 450, 'Route 1', 'FireRed/LeafGreen'),
    'route-2': RegionMarker(350, 380, 'Route 2', 'FRLG'),
    'route-3': RegionMarker(500, 350, 'Route 3', 'FRLG'),
    'route-4': RegionMarker(550, 300, 'Route 4', 'FRLG'),
    'route-5': RegionMarker(450, 250, 'Route 5', 'FRLG'),
    'route-6': RegionMarker(400, 350, 'Route 6', 'FRLG'),
    'viridian-forest': RegionMarker(350, 400, 'Viridian Forest', 'FRLG'),
    'mt-moon': RegionMarker(480, 350, 'Mt. Moon', 'FRLG'),
    'rock-tunnel': RegionMarker(550, 280, 'Rock Tunnel', 'FRLG'),
    'pokemon-tower': RegionMarker(600, 320, 'Pokemon Tower', 'FRLG'),
    'seafoam-islands': RegionMarker(300, 480, 'Seafoam Islands', 'FRLG'),
    'victory-road': RegionMarker(200, 200, 'Victory Road', 'FRLG'),
    'cerulean-cave': RegionMarker(450, 200, 'Cerulean Cave', 'FRLG'),
  },
  'johto': {
    'route-29': RegionMarker(300, 450, 'Route 29', 'HeartGold/SoulSilver'),
    'route-30': RegionMarker(320, 400, 'Route 30', 'HGSS'),
    'route-31': RegionMarker(380, 380, 'Route 31', 'HGSS'),
    'route-32': RegionMarker(450, 420, 'Route 32', 'HGSS'),
    'route-33': RegionMarker(520, 400, 'Route 33', 'HGSS'),
    'route-34': RegionMarker(480, 350, 'Route 34', 'HGSS'),
    'sprout-tower': RegionMarker(330, 420, 'Sprout Tower', 'HGSS'),
    'union-cave': RegionMarker(440, 430, 'Union Cave', 'HGSS'),
    'slowpoke-well': RegionMarker(490, 360, 'Slowpoke Well', 'HGSS'),
    'ilex-forest': RegionMarker(510, 380, 'Ilex Forest', 'HGSS'),
    'burned-tower': RegionMarker(550, 340, 'Burned Tower', 'HGSS'),
    'bell-tower': RegionMarker(570, 330, 'Bell Tower', 'HGSS'),
    'whirl-islands': RegionMarker(350, 500, 'Whirl Islands', 'HGSS'),
    'mt-mortar': RegionMarker(480, 300, 'Mt. Mortar', 'HGSS'),
    'ice-path': RegionMarker(600, 250, 'Ice Path', 'HGSS'),
    'dragon-den': RegionMarker(650, 280, 'Dragon\'s Den', 'HGSS'),
  },
  'hoenn': {
    'route-101': RegionMarker(380, 480, 'Route 101', 'Emerald'),
    'route-102': RegionMarker(350, 450, 'Route 102', 'Emerald'),
    'route-103': RegionMarker(420, 440, 'Route 103', 'Emerald'),
    'route-104': RegionMarker(320, 400, 'Route 104', 'Emerald'),
    'route-110': RegionMarker(450, 380, 'Route 110', 'Emerald'),
    'route-111': RegionMarker(500, 350, 'Route 111', 'Emerald'),
    'route-119': RegionMarker(480, 280, 'Route 119', 'Emerald'),
    'petalburg-woods': RegionMarker(300, 420, 'Petalburg Woods', 'Emerald'),
    'meteor-falls': RegionMarker(520, 320, 'Meteor Falls', 'Emerald'),
    'granite-cave': RegionMarker(420, 400, 'Granite Cave', 'Emerald'),
    'fiery-path': RegionMarker(540, 340, 'Fiery Path', 'Emerald'),
    'jagged-pass': RegionMarker(560, 310, 'Jagged Pass', 'Emerald'),
    'mt-pyre': RegionMarker(600, 350, 'Mt. Pyre', 'Emerald'),
    'seafloor-cavern': RegionMarker(650, 420, 'Seafloor Cavern', 'Emerald'),
    'cave-of-origin': RegionMarker(620, 300, 'Cave of Origin', 'Emerald'),
    'sky-pillar': RegionMarker(700, 250, 'Sky Pillar', 'Emerald'),
  },
  'sinnoh': {
    'route-201': RegionMarker(400, 450, 'Route 201', 'Platinum'),
    'route-202': RegionMarker(420, 420, 'Route 202', 'Platinum'),
    'route-203': RegionMarker(450, 400, 'Route 203', 'Platinum'),
    'route-204': RegionMarker(380, 380, 'Route 204', 'Platinum'),
    'route-205': RegionMarker(420, 350, 'Route 205', 'Platinum'),
    'route-206': RegionMarker(400, 320, 'Route 206', 'Platinum'),
    'eterna-forest': RegionMarker(350, 360, 'Eterna Forest', 'Platinum'),
    'oreburgh-gate': RegionMarker(480, 430, 'Oreburgh Gate', 'Platinum'),
    'oreburgh-mine': RegionMarker(500, 440, 'Oreburgh Mine', 'Platinum'),
    'ravaged-path': RegionMarker(360, 390, 'Ravaged Path', 'Platinum'),
    'wayward-cave': RegionMarker(420, 310, 'Wayward Cave', 'Platinum'),
    'mt-coronet': RegionMarker(480, 320, 'Mt. Coronet', 'Platinum'),
    'iron-island': RegionMarker(250, 280, 'Iron Island', 'Platinum'),
    'old-chateau': RegionMarker(320, 340, 'Old Chateau', 'Platinum'),
    'lake-verity': RegionMarker(380, 460, 'Lake Verity', 'Platinum'),
    'lake-valor': RegionMarker(550, 380, 'Lake Valor', 'Platinum'),
    'lake-acuity': RegionMarker(600, 200, 'Lake Acuity', 'Platinum'),
    'victory-road': RegionMarker(520, 250, 'Victory Road', 'Platinum'),
    'stark-mountain': RegionMarker(650, 320, 'Stark Mountain', 'Platinum'),
    'turnback-cave': RegionMarker(700, 280, 'Turnback Cave', 'Platinum'),
  },
  'unova': {
    'route-1': RegionMarker(400, 480, 'Route 1', 'Black/White'),
    'route-2': RegionMarker(420, 450, 'Route 2', 'BW'),
    'route-3': RegionMarker(480, 430, 'Route 3', 'BW'),
    'route-4': RegionMarker(540, 400, 'Route 4', 'BW'),
    'dreamyard': RegionMarker(380, 460, 'Dreamyard', 'BW'),
    'pinwheel-forest': RegionMarker(350, 420, 'Pinwheel Forest', 'BW'),
    'desert-resort': RegionMarker(560, 380, 'Desert Resort', 'BW'),
    'relic-castle': RegionMarker(580, 370, 'Relic Castle', 'BW'),
    'chargestone-cave': RegionMarker(480, 350, 'Chargestone Cave', 'BW'),
    'twist-mountain': RegionMarker(520, 300, 'Twist Mountain', 'BW'),
    'dragonspiral-tower': RegionMarker(600, 280, 'Dragonspiral Tower', 'BW'),
    'celestial-tower': RegionMarker(450, 320, 'Celestial Tower', 'BW'),
    'victory-road': RegionMarker(650, 220, 'Victory Road', 'BW'),
    'giants-chasm': RegionMarker(680, 200, 'Giant\'s Chasm', 'BW'),
  },
  'kalos': {
    'route-1': RegionMarker(400, 480, 'Route 1', 'X/Y'),
    'route-2': RegionMarker(380, 450, 'Route 2', 'X/Y'),
    'route-3': RegionMarker(420, 420, 'Route 3', 'X/Y'),
    'santalune-forest': RegionMarker(360, 460, 'Santalune Forest', 'X/Y'),
    'connecting-cave': RegionMarker(450, 400, 'Connecting Cave', 'X/Y'),
    'glittering-cave': RegionMarker(480, 380, 'Glittering Cave', 'X/Y'),
    'reflection-cave': RegionMarker(520, 350, 'Reflection Cave', 'X/Y'),
    'frost-cavern': RegionMarker(550, 300, 'Frost Cavern', 'X/Y'),
    'pokemon-village': RegionMarker(580, 250, 'Pokemon Village', 'X/Y'),
    'victory-road': RegionMarker(620, 220, 'Victory Road', 'X/Y'),
    'terminus-cave': RegionMarker(500, 320, 'Terminus Cave', 'X/Y'),
  },
  'alola': {
    'route-1': RegionMarker(420, 350, 'Route 1', 'Sun/Moon'),
    'route-2': RegionMarker(380, 320, 'Route 2', 'SM'),
    'route-3': RegionMarker(450, 300, 'Route 3', 'SM'),
    'melemele-meadow': RegionMarker(400, 380, 'Melemele Meadow', 'SM'),
    'verdant-cavern': RegionMarker(430, 340, 'Verdant Cavern', 'SM'),
    'seaward-cave': RegionMarker(360, 360, 'Seaward Cave', 'SM'),
    'ten-carat-hill': RegionMarker(440, 370, 'Ten Carat Hill', 'SM'),
    'brooklet-hill': RegionMarker(300, 280, 'Brooklet Hill', 'SM'),
    'wela-volcano-park': RegionMarker(500, 320, 'Wela Volcano Park', 'SM'),
    'lush-jungle': RegionMarker(350, 250, 'Lush Jungle', 'SM'),
    'mount-lanakila': RegionMarker(400, 200, 'Mount Lanakila', 'SM'),
    'vast-poni-canyon': RegionMarker(600, 380, 'Vast Poni Canyon', 'SM'),
  },
  'galar': {
    'route-1': RegionMarker(400, 480, 'Route 1', 'Sword/Shield'),
    'route-2': RegionMarker(420, 450, 'Route 2', 'SwSh'),
    'route-3': RegionMarker(380, 420, 'Route 3', 'SwSh'),
    'galar-mine': RegionMarker(440, 400, 'Galar Mine', 'SwSh'),
    'galar-mine-no-2': RegionMarker(460, 380, 'Galar Mine No. 2', 'SwSh'),
    'rolling-fields': RegionMarker(350, 400, 'Rolling Fields', 'SwSh'),
    'dappled-grove': RegionMarker(370, 380, 'Dappled Grove', 'SwSh'),
    'watchtower-ruins': RegionMarker(400, 360, 'Watchtower Ruins', 'SwSh'),
    'motostoke-riverbank': RegionMarker(480, 420, 'Motostoke Riverbank', 'SwSh'),
    'dusty-bowl': RegionMarker(500, 340, 'Dusty Bowl', 'SwSh'),
    'giant-mirror': RegionMarker(520, 320, 'Giant\'s Mirror', 'SwSh'),
    'hammerlocke-hills': RegionMarker(540, 300, 'Hammerlocke Hills', 'SwSh'),
    'slumbering-weald': RegionMarker(420, 460, 'Slumbering Weald', 'SwSh'),
    'glimwood-tangle': RegionMarker(480, 280, 'Glimwood Tangle', 'SwSh'),
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
