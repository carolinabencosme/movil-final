import 'dart:convert';

import 'package:test/test.dart';
import 'package:pokedex/models/pokemon_model.dart';

void main() {
  group('_extractSpriteUrl via PokemonListItem', () {
    test('returns front_default when available', () {
      final item = PokemonListItem.fromGraphQL({
        'id': 1,
        'name': 'bulbasaur',
        'pokemon_v2_pokemonsprites': _buildSpriteEntries({
          'front_default': 'https://example.com/front_default.png',
          'other': {
            'official-artwork': {
              'front_default': 'https://example.com/official.png',
            },
          },
        }),
      });

      expect(item.imageUrl, 'https://example.com/front_default.png');
    });

    test('falls back to official artwork', () {
      final item = PokemonListItem.fromGraphQL({
        'id': 2,
        'name': 'ivysaur',
        'pokemon_v2_pokemonsprites': _buildSpriteEntries({
          'other': {
            'official-artwork': {
              'front_default': 'https://example.com/official.png',
            },
          },
        }),
      });

      expect(item.imageUrl, 'https://example.com/official.png');
    });

    test('falls back to home front_default', () {
      final item = PokemonListItem.fromGraphQL({
        'id': 3,
        'name': 'venusaur',
        'pokemon_v2_pokemonsprites': _buildSpriteEntries({
          'other': {
            'home': {
              'front_default': 'https://example.com/home.png',
            },
          },
        }),
      });

      expect(item.imageUrl, 'https://example.com/home.png');
    });

    test('returns empty string when sprites are invalid', () {
      final item = PokemonListItem.fromGraphQL({
        'id': 4,
        'name': 'charmander',
        'pokemon_v2_pokemonsprites': [
          {
            'sprites': '{invalid json}',
          }
        ],
      });

      expect(item.imageUrl, '');
    });

    test('falls back to the first valid sprite entry', () {
      final item = PokemonListItem.fromGraphQL({
        'id': 5,
        'name': 'charmeleon',
        'pokemon_v2_pokemonsprites': [
          {
            'sprites': '{invalid json}',
          },
          {
            'sprites': jsonEncode({
              'front_default': 'https://example.com/fallback.png',
            }),
          },
        ],
      });

      expect(item.imageUrl, 'https://example.com/fallback.png');
    });
  });
}

List<Map<String, dynamic>> _buildSpriteEntries(Map<String, dynamic> sprites) {
  return [
    {
      'sprites': jsonEncode(sprites),
    }
  ];
}
