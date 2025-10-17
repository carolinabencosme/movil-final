class Pokemon {
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final String spriteUrl;

  Pokemon({
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.spriteUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List<dynamic>)
          .map((typeEntry) =>
              (typeEntry['type'] as Map<String, dynamic>)['name'] as String)
          .toList(),
      spriteUrl: ((json['sprites'] as Map<String, dynamic>)['front_default']
              as String?) ??
          '',
    );
  }
}
