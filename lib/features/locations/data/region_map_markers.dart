/// Coordenadas X/Y para marcadores en los mapas de regiones Pokémon
///
/// Las coordenadas son relativas a imágenes de 800x600 píxeles.
/// Ajusta estas coordenadas cuando reemplaces con mapas reales.

/// Clase para representar un marcador en el mapa de región
class RegionMarker {
  const RegionMarker(this.x, this.y, this.area);

  /// Posición X en píxeles (0-800)
  final double x;

  /// Posición Y en píxeles (0-600)
  final double y;

  /// Nombre del área (ej: "Route 1", "Viridian Forest")
  final String area;
}

/// Mapa de marcadores por región
///
/// Cada región tiene un diccionario de ubicaciones con sus coordenadas X/Y.
/// Las claves son los nombres de las áreas normalizadas (ej: "route-1", "viridian-forest").
const Map<String, Map<String, RegionMarker>> regionMarkers = {
  'kanto': {
    'route-1': RegionMarker(400, 450, 'Route 1'),
    'route-2': RegionMarker(350, 380, 'Route 2'),
    'route-3': RegionMarker(500, 350, 'Route 3'),
    'route-4': RegionMarker(550, 300, 'Route 4'),
    'route-5': RegionMarker(450, 250, 'Route 5'),
    'route-6': RegionMarker(400, 350, 'Route 6'),
    'viridian-forest': RegionMarker(350, 400, 'Viridian Forest'),
    'mt-moon': RegionMarker(480, 350, 'Mt. Moon'),
    'rock-tunnel': RegionMarker(550, 280, 'Rock Tunnel'),
    'pokemon-tower': RegionMarker(600, 320, 'Pokemon Tower'),
    'seafoam-islands': RegionMarker(300, 480, 'Seafoam Islands'),
    'victory-road': RegionMarker(200, 200, 'Victory Road'),
    'cerulean-cave': RegionMarker(450, 200, 'Cerulean Cave'),
  },
  'johto': {
    'route-29': RegionMarker(300, 450, 'Route 29'),
    'route-30': RegionMarker(320, 400, 'Route 30'),
    'route-31': RegionMarker(380, 380, 'Route 31'),
    'route-32': RegionMarker(450, 420, 'Route 32'),
    'route-33': RegionMarker(520, 400, 'Route 33'),
    'route-34': RegionMarker(480, 350, 'Route 34'),
    'sprout-tower': RegionMarker(330, 420, 'Sprout Tower'),
    'union-cave': RegionMarker(440, 430, 'Union Cave'),
    'slowpoke-well': RegionMarker(490, 360, 'Slowpoke Well'),
    'ilex-forest': RegionMarker(510, 380, 'Ilex Forest'),
    'burned-tower': RegionMarker(550, 340, 'Burned Tower'),
    'bell-tower': RegionMarker(570, 330, 'Bell Tower'),
    'whirl-islands': RegionMarker(350, 500, 'Whirl Islands'),
    'mt-mortar': RegionMarker(480, 300, 'Mt. Mortar'),
    'ice-path': RegionMarker(600, 250, 'Ice Path'),
    'dragon-den': RegionMarker(650, 280, 'Dragon\'s Den'),
  },
  'hoenn': {
    'route-101': RegionMarker(380, 480, 'Route 101'),
    'route-102': RegionMarker(350, 450, 'Route 102'),
    'route-103': RegionMarker(420, 440, 'Route 103'),
    'route-104': RegionMarker(320, 400, 'Route 104'),
    'route-110': RegionMarker(450, 380, 'Route 110'),
    'route-111': RegionMarker(500, 350, 'Route 111'),
    'route-119': RegionMarker(480, 280, 'Route 119'),
    'petalburg-woods': RegionMarker(300, 420, 'Petalburg Woods'),
    'meteor-falls': RegionMarker(520, 320, 'Meteor Falls'),
    'granite-cave': RegionMarker(420, 400, 'Granite Cave'),
    'fiery-path': RegionMarker(540, 340, 'Fiery Path'),
    'jagged-pass': RegionMarker(560, 310, 'Jagged Pass'),
    'mt-pyre': RegionMarker(600, 350, 'Mt. Pyre'),
    'seafloor-cavern': RegionMarker(650, 420, 'Seafloor Cavern'),
    'cave-of-origin': RegionMarker(620, 300, 'Cave of Origin'),
    'sky-pillar': RegionMarker(700, 250, 'Sky Pillar'),
  },
  'sinnoh': {
    'route-201': RegionMarker(400, 450, 'Route 201'),
    'route-202': RegionMarker(420, 420, 'Route 202'),
    'route-203': RegionMarker(450, 400, 'Route 203'),
    'route-204': RegionMarker(380, 380, 'Route 204'),
    'route-205': RegionMarker(420, 350, 'Route 205'),
    'route-206': RegionMarker(400, 320, 'Route 206'),
    'eterna-forest': RegionMarker(350, 360, 'Eterna Forest'),
    'oreburgh-gate': RegionMarker(480, 430, 'Oreburgh Gate'),
    'oreburgh-mine': RegionMarker(500, 440, 'Oreburgh Mine'),
    'ravaged-path': RegionMarker(360, 390, 'Ravaged Path'),
    'wayward-cave': RegionMarker(420, 310, 'Wayward Cave'),
    'mt-coronet': RegionMarker(480, 320, 'Mt. Coronet'),
    'iron-island': RegionMarker(250, 280, 'Iron Island'),
    'old-chateau': RegionMarker(320, 340, 'Old Chateau'),
    'lake-verity': RegionMarker(380, 460, 'Lake Verity'),
    'lake-valor': RegionMarker(550, 380, 'Lake Valor'),
    'lake-acuity': RegionMarker(600, 200, 'Lake Acuity'),
    'victory-road': RegionMarker(520, 250, 'Victory Road'),
    'stark-mountain': RegionMarker(650, 320, 'Stark Mountain'),
    'turnback-cave': RegionMarker(700, 280, 'Turnback Cave'),
  },
  'unova': {
    'route-1': RegionMarker(400, 480, 'Route 1'),
    'route-2': RegionMarker(420, 450, 'Route 2'),
    'route-3': RegionMarker(480, 430, 'Route 3'),
    'route-4': RegionMarker(540, 400, 'Route 4'),
    'dreamyard': RegionMarker(380, 460, 'Dreamyard'),
    'pinwheel-forest': RegionMarker(350, 420, 'Pinwheel Forest'),
    'desert-resort': RegionMarker(560, 380, 'Desert Resort'),
    'relic-castle': RegionMarker(580, 370, 'Relic Castle'),
    'chargestone-cave': RegionMarker(480, 350, 'Chargestone Cave'),
    'twist-mountain': RegionMarker(520, 300, 'Twist Mountain'),
    'dragonspiral-tower': RegionMarker(600, 280, 'Dragonspiral Tower'),
    'celestial-tower': RegionMarker(450, 320, 'Celestial Tower'),
    'victory-road': RegionMarker(650, 220, 'Victory Road'),
    'giants-chasm': RegionMarker(680, 200, 'Giant\'s Chasm'),
  },
  'kalos': {
    'route-1': RegionMarker(400, 480, 'Route 1'),
    'route-2': RegionMarker(380, 450, 'Route 2'),
    'route-3': RegionMarker(420, 420, 'Route 3'),
    'santalune-forest': RegionMarker(360, 460, 'Santalune Forest'),
    'connecting-cave': RegionMarker(450, 400, 'Connecting Cave'),
    'glittering-cave': RegionMarker(480, 380, 'Glittering Cave'),
    'reflection-cave': RegionMarker(520, 350, 'Reflection Cave'),
    'frost-cavern': RegionMarker(550, 300, 'Frost Cavern'),
    'pokemon-village': RegionMarker(580, 250, 'Pokemon Village'),
    'victory-road': RegionMarker(620, 220, 'Victory Road'),
    'terminus-cave': RegionMarker(500, 320, 'Terminus Cave'),
  },
  'alola': {
    'route-1': RegionMarker(420, 350, 'Route 1'),
    'route-2': RegionMarker(380, 320, 'Route 2'),
    'route-3': RegionMarker(450, 300, 'Route 3'),
    'melemele-meadow': RegionMarker(400, 380, 'Melemele Meadow'),
    'verdant-cavern': RegionMarker(430, 340, 'Verdant Cavern'),
    'seaward-cave': RegionMarker(360, 360, 'Seaward Cave'),
    'ten-carat-hill': RegionMarker(440, 370, 'Ten Carat Hill'),
    'brooklet-hill': RegionMarker(300, 280, 'Brooklet Hill'),
    'wela-volcano-park': RegionMarker(500, 320, 'Wela Volcano Park'),
    'lush-jungle': RegionMarker(350, 250, 'Lush Jungle'),
    'mount-lanakila': RegionMarker(400, 200, 'Mount Lanakila'),
    'vast-poni-canyon': RegionMarker(600, 380, 'Vast Poni Canyon'),
  },
  'galar': {
    'route-1': RegionMarker(400, 480, 'Route 1'),
    'route-2': RegionMarker(420, 450, 'Route 2'),
    'route-3': RegionMarker(380, 420, 'Route 3'),
    'galar-mine': RegionMarker(440, 400, 'Galar Mine'),
    'galar-mine-no-2': RegionMarker(460, 380, 'Galar Mine No. 2'),
    'rolling-fields': RegionMarker(350, 400, 'Rolling Fields'),
    'dappled-grove': RegionMarker(370, 380, 'Dappled Grove'),
    'watchtower-ruins': RegionMarker(400, 360, 'Watchtower Ruins'),
    'motostoke-riverbank': RegionMarker(480, 420, 'Motostoke Riverbank'),
    'dusty-bowl': RegionMarker(500, 340, 'Dusty Bowl'),
    'giant-mirror': RegionMarker(520, 320, 'Giant\'s Mirror'),
    'hammerlocke-hills': RegionMarker(540, 300, 'Hammerlocke Hills'),
    'slumbering-weald': RegionMarker(420, 460, 'Slumbering Weald'),
    'glimwood-tangle': RegionMarker(480, 280, 'Glimwood Tangle'),
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
  return RegionMarker(400, 300, regionName);
}
