# Evolution Chain Implementation

## Overview
This document describes the complete evolution chain display implementation according to the specification.

## Implementation Details

### GraphQL Query
The query has been updated to match the specification exactly:
```graphql
query PokemonDetails($where: pokemon_v2_pokemon_bool_exp!) {
  pokemon_v2_pokemon(where: $where, limit: 1) {
    id
    name
    height
    weight
    
    pokemon_v2_pokemontypes {
      pokemon_v2_type { name }
    }
    
    pokemon_v2_pokemonspecy {
      pokemon_v2_pokemonspeciesflavortexts(
        where: {language_id: {_eq: 7}}
        order_by: {version_id: desc}
        limit: 1
      ) { flavor_text }
      
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {order: asc}) {
          id
          name
          evolves_from_species_id
        }
      }
    }
  }
}
```

### Evolution Chain Logic

#### Helper Classes
```dart
class _Species {
  final int id;
  final String name;
  final int? parentId;  // evolves_from_species_id
  final String imageUrl;
}
```

#### Key Functions
1. **speciesMapFromRaw()**: Converts API response to a Map<int, _Species>
2. **preChain()**: Gets complete pre-evolution chain including current Pokemon
3. **forwardChains()**: Gets all forward evolution branches from current Pokemon

### Display Logic

#### Linear Evolutions (Single Chain)
Example: Charmander → Charmeleon → Charizard

**Display**: Horizontal scrollable row with arrow icons
```
[Charmander] → [Charmeleon] → [Charizard]
```

**Component**: `_LinearEvolutionChain`
- Uses SingleChildScrollView with horizontal axis
- Row of evolution cards with arrow icons between them
- Current Pokemon highlighted with colored border

#### Branched Evolutions (Multiple Chains)
Example: Eevee → Vaporeon, Jolteon, Flareon, etc.

**Display**: Ramified/circular layout
```
          [Eevee]
             ↓
    ┌────────┼────────┐
    ↓        ↓        ↓
[Vaporeon] [Jolteon] [Flareon] ...
```

**Component**: `_BranchedEvolutionDisplay`
- Shows current Pokemon at top center
- Downward arrow
- Wrap widget displays all branches
- Each branch is a vertical Column of evolution cards

### Evolution Card Component

**_EvolutionCard features**:
- Pokemon sprite (80x80) with Hero animation
- Pokemon name (capitalized)
- Highlighted border for current Pokemon
- Shadow effect for current Pokemon
- Tappable for navigation (except current)
- Error handling for missing images

**Styling**:
- Border: Primary color for current, subtle outline for others
- Background: Primary container for current, surface for others
- Text: Contrast colors based on background
- Border radius: 20px
- Size: 120px width
- Padding: 12px

### Navigation & Animations

**Hero Animation**:
```dart
Hero(
  tag: 'pokemon-artwork-${species.id}',
  child: Image.network(imageUrl),
)
```

**Navigation**:
```dart
onTap: () {
  _pendingEvolutionNavigation[species.name] = species.id;
  context.push('/pokedex/${species.name}');
}
```

### Scrolling Behavior

**Vertical Scrolling**: 
- Each tab (including Evoluciones) wrapped in SingleChildScrollView
- Physics: BouncingScrollPhysics with AlwaysScrollableScrollPhysics parent
- Bottom padding accounts for safe area

**Horizontal Scrolling**:
- Linear evolution chains use horizontal SingleChildScrollView
- Allows viewing long evolution chains (3+ stages)

## Testing Guide

### Test Cases

#### 1. Linear Evolution (3 stages)
**Pokemon**: Charmander (ID: 4)
- Expected: Charmander → Charmeleon → Charizard
- Display: Horizontal row with arrows
- Current: Highlighted with primary border

**Pokemon**: Bulbasaur (ID: 1)
- Expected: Bulbasaur → Ivysaur → Venusaur
- Display: Horizontal row with arrows

#### 2. Pre-evolution Chain
**Pokemon**: Pikachu (ID: 25)
- Expected: Pichu → Pikachu → Raichu
- Display: Horizontal row showing full chain
- Current: Pikachu highlighted in middle

#### 3. Branched Evolution
**Pokemon**: Eevee (ID: 133)
- Expected: Eevee at top, 8 evolutions below
- Display: Ramified layout with Wrap
- Branches: Vaporeon, Jolteon, Flareon, Espeon, Umbreon, Leafeon, Glaceon, Sylveon

**Pokemon**: Tyrogue (ID: 236)
- Expected: Tyrogue at top, 3 evolutions below
- Display: Ramified layout
- Branches: Hitmonlee, Hitmonchan, Hitmontop

#### 4. No Evolution
**Pokemon**: Ditto (ID: 132)
- Expected: "Este Pokémon no tiene evoluciones posteriores."
- Display: Text message only

#### 5. Two-stage with Branch
**Pokemon**: Wurmple (ID: 265)
- Expected: Two separate evolution lines
- Display: Ramified layout
- Branches: Wurmple → Silcoon → Beautifly, Wurmple → Cascoon → Dustox

### Manual Testing Steps

1. **Launch the app** and navigate to Pokédex
2. **Search for a Pokemon** (e.g., "Charmander")
3. **Open detail view** by tapping the card
4. **Navigate to "Evoluciones" tab** (4th tab)
5. **Verify display**:
   - ✓ Complete chain visible
   - ✓ Current Pokemon highlighted
   - ✓ Correct layout (linear vs branched)
   - ✓ Images load properly
   - ✓ No overflow or clipping
6. **Test scrolling**: Scroll vertically to see entire chain
7. **Test navigation**: Tap another Pokemon in chain
8. **Verify Hero animation**: Smooth image transition
9. **Repeat** with different Pokemon types

### Visual Verification Checklist

- [ ] Linear chains display horizontally with arrows
- [ ] Branched chains display in wrap layout
- [ ] Current Pokemon has colored border and shadow
- [ ] Other Pokemon have subtle borders
- [ ] Images are 80x80 pixels
- [ ] Text is centered and capitalized
- [ ] No overflow errors
- [ ] Vertical scrolling works smoothly
- [ ] Horizontal scrolling works for long chains
- [ ] Hero animations are smooth
- [ ] Navigation updates detail view
- [ ] Error images show placeholder icon

## Code Files Modified

1. **lib/queries/get_pokemon_details.dart**
   - Updated GraphQL query
   - Removed languageId parameter

2. **lib/models/pokemon_model.dart**
   - Updated PokemonEvolutionChain.fromGraphQL
   - Changed field names to match new query

3. **lib/screens/detail_screen.dart**
   - Added _Species helper class
   - Added helper functions (preChain, forwardChains)
   - Replaced _EvolutionSection implementation
   - Added _LinearEvolutionChain widget
   - Added _BranchedEvolutionDisplay widget
   - Added _EvolutionCard widget
   - Updated to use pokemon_v2_pokemonspecy

## Future Enhancements

1. **Evolution Conditions**: Display level/item requirements
2. **Mega Evolutions**: Handle alternative forms
3. **Regional Variants**: Show regional variants
4. **Stats Comparison**: Show stat changes during evolution
5. **Animation**: Add entrance animations for cards
6. **Filters**: Filter by evolution method

## Troubleshooting

### Images Not Loading
- Check network connection
- Verify species ID is valid
- Check sprite URL format
- Fallback placeholder should show

### Navigation Not Working
- Verify context.push extension is available
- Check _pendingEvolutionNavigation map
- Ensure species.name is not empty

### Overflow Issues
- Check SingleChildScrollView wrapper
- Verify padding values
- Check Wrap spacing values

### Wrong Evolution Chain
- Verify GraphQL query response
- Check evolves_from_species_id parsing
- Debug preChain and forwardChains logic

## API Reference

### PokeAPI GraphQL Endpoint
```
https://beta.pokeapi.co/graphql/v1beta
```

### Sprite URL Format
```
https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png
```

## Dependencies

- flutter: SDK
- graphql_flutter: ^5.2.1
- No additional dependencies required

## Conclusion

This implementation provides a complete, scrollable evolution chain display that:
- Follows the specification exactly
- Handles both linear and branched evolutions
- Provides smooth navigation and animations
- Is fully responsive and scrollable
- Handles edge cases and errors gracefully
