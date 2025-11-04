import 'package:test/test.dart';
import 'package:pokedex/models/evolution_chain_model.dart';

void main() {
  group('EvolutionChain', () {
    test('identifies linear evolution chain correctly', () {
      final chainData = {
        'pokemon_v2_pokemonspecies': [
          {
            'id': 1,
            'name': 'bulbasaur',
            'order': 1,
            'evolves_from_species_id': null,
            'pokemon_v2_pokemons': [
              {
                'id': 1,
                'name': 'bulbasaur',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
          {
            'id': 2,
            'name': 'ivysaur',
            'order': 2,
            'evolves_from_species_id': 1,
            'pokemon_v2_pokemons': [
              {
                'id': 2,
                'name': 'ivysaur',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [
              {
                'min_level': 16,
                'evolution_trigger_id': 1,
                'pokemon_v2_evolutiontrigger': {'name': 'level-up'}
              }
            ],
          },
          {
            'id': 3,
            'name': 'venusaur',
            'order': 3,
            'evolves_from_species_id': 2,
            'pokemon_v2_pokemons': [
              {
                'id': 3,
                'name': 'venusaur',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [
              {
                'min_level': 32,
                'evolution_trigger_id': 1,
                'pokemon_v2_evolutiontrigger': {'name': 'level-up'}
              }
            ],
          },
        ],
      };

      final chain = EvolutionChain.fromGraphQL(chainData);

      expect(chain.species.length, 3);
      expect(chain.isBranched, false);
      expect(chain.root?.name, 'bulbasaur');
    });

    test('identifies branched evolution chain correctly', () {
      final chainData = {
        'pokemon_v2_pokemonspecies': [
          {
            'id': 133,
            'name': 'eevee',
            'order': 1,
            'evolves_from_species_id': null,
            'pokemon_v2_pokemons': [
              {
                'id': 133,
                'name': 'eevee',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
          {
            'id': 134,
            'name': 'vaporeon',
            'order': 2,
            'evolves_from_species_id': 133,
            'pokemon_v2_pokemons': [
              {
                'id': 134,
                'name': 'vaporeon',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
          {
            'id': 135,
            'name': 'jolteon',
            'order': 3,
            'evolves_from_species_id': 133,
            'pokemon_v2_pokemons': [
              {
                'id': 135,
                'name': 'jolteon',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
          {
            'id': 136,
            'name': 'flareon',
            'order': 4,
            'evolves_from_species_id': 133,
            'pokemon_v2_pokemons': [
              {
                'id': 136,
                'name': 'flareon',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
        ],
      };

      final chain = EvolutionChain.fromGraphQL(chainData);

      expect(chain.species.length, 4);
      expect(chain.isBranched, true);
      expect(chain.root?.name, 'eevee');
      expect(chain.getEvolutionsFrom(133).length, 3);
    });

    test('getEvolutionsFrom returns correct children', () {
      final chainData = {
        'pokemon_v2_pokemonspecies': [
          {
            'id': 1,
            'name': 'bulbasaur',
            'order': 1,
            'evolves_from_species_id': null,
            'pokemon_v2_pokemons': [
              {
                'id': 1,
                'name': 'bulbasaur',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
          {
            'id': 2,
            'name': 'ivysaur',
            'order': 2,
            'evolves_from_species_id': 1,
            'pokemon_v2_pokemons': [
              {
                'id': 2,
                'name': 'ivysaur',
                'pokemon_v2_pokemonsprites': [],
              }
            ],
            'pokemon_v2_pokemonevolutions': [],
          },
        ],
      };

      final chain = EvolutionChain.fromGraphQL(chainData);
      final evolutions = chain.getEvolutionsFrom(1);

      expect(evolutions.length, 1);
      expect(evolutions.first.name, 'ivysaur');
    });
  });

  group('EvolutionSpecies', () {
    test('parses evolution data correctly', () {
      final speciesData = {
        'id': 2,
        'name': 'ivysaur',
        'order': 2,
        'evolves_from_species_id': 1,
        'pokemon_v2_pokemons': [
          {
            'id': 2,
            'name': 'ivysaur',
            'pokemon_v2_pokemonsprites': [
              {
                'sprites': '{"front_default": "https://example.com/ivysaur.png"}',
              }
            ],
          }
        ],
        'pokemon_v2_pokemonevolutions': [
          {
            'min_level': 16,
            'evolution_trigger_id': 1,
            'pokemon_v2_evolutiontrigger': {'name': 'level-up'}
          }
        ],
      };

      final species = EvolutionSpecies.fromGraphQL(speciesData);

      expect(species.id, 2);
      expect(species.name, 'ivysaur');
      expect(species.evolvesFromSpeciesId, 1);
      expect(species.pokemonId, 2);
      expect(species.pokemonName, 'ivysaur');
      expect(species.minLevel, 16);
      expect(species.evolutionTrigger, 'level-up');
      expect(species.imageUrl, 'https://example.com/ivysaur.png');
    });

    test('handles missing evolution data', () {
      final speciesData = {
        'id': 1,
        'name': 'bulbasaur',
        'order': 1,
        'evolves_from_species_id': null,
        'pokemon_v2_pokemons': [
          {
            'id': 1,
            'name': 'bulbasaur',
            'pokemon_v2_pokemonsprites': [],
          }
        ],
        'pokemon_v2_pokemonevolutions': [],
      };

      final species = EvolutionSpecies.fromGraphQL(speciesData);

      expect(species.id, 1);
      expect(species.name, 'bulbasaur');
      expect(species.evolvesFromSpeciesId, null);
      expect(species.minLevel, null);
      expect(species.evolutionTrigger, null);
    });
  });
}
