import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../../../theme/pokemon_type_colors.dart';
import '../detail_constants.dart';
import '../detail_helper_widgets.dart';

/// Sección que muestra los movimientos del Pokémon con filtrado y paginación
/// 
/// Presenta la lista de movimientos que un Pokémon puede aprender con:
/// - **Filtros por método de aprendizaje** (level-up, TM, egg moves, tutor, etc.)
/// - **Filtros por versión del juego** (Black 2 White 2, Ultra Sun Ultra Moon, etc.)
/// - **Deduplicación de movimientos**: Evita que el mismo movimiento aparezca múltiples veces
/// - Filtro para mostrar solo movimientos con nivel definido
/// - **Paginación lazy loading**: Carga movimientos incrementalmente mientras el usuario hace scroll
/// - Ordenamiento por nivel y nombre
/// 
/// La paginación evita renderizar cientos de movimientos de golpe, mejorando
/// significativamente el rendimiento especialmente en Pokémon con muchos movimientos.
/// 
/// La deduplicación se basa en el nombre del movimiento, mostrando solo una entrada
/// por movimiento único para evitar repeticiones entre diferentes versiones del juego.
class MovesSection extends StatefulWidget {
  const MovesSection({
    super.key,
    required this.moves,
    required this.formatLabel,
  });

  /// Lista completa de movimientos del Pokémon desde la API
  final List<PokemonMove> moves;
  
  /// Función para formatear etiquetas de texto (capitalización)
  final String Function(String) formatLabel;

  @override
  State<MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<MovesSection> {
  /// Método de aprendizaje seleccionado para filtrar (null = todos)
  String? _selectedMethod;
  
  /// Versión del juego seleccionada para filtrar (null = todos)
  String? _selectedGame;
  
  /// Si es true, solo muestra movimientos que tienen nivel definido
  bool _onlyWithLevel = false;
  
  /// Número de movimientos a mostrar inicialmente y por cada carga
  static const int _pageSize = 15;
  
  /// Contador de movimientos actualmente visibles
  int _displayedMovesCount = _pageSize;

  /// Resuelve el nombre a mostrar de un movimiento

  String _resolveDisplayName(String value) {
    if (value.isEmpty) {
      return 'Movimiento desconocido';
    }
    final lowercase = value.toLowerCase();
    if (value == lowercase) {
      return widget.formatLabel(value);
    }
    return value;
  }

  String _formatMethod(String method) {
    if (method.toLowerCase() == 'unknown') {
      return 'Desconocido';
    }
    return widget.formatLabel(method);
  }

  /// Formatea el nombre de la versión del juego para mostrar
  String _formatVersionGroup(String versionGroup) {
    if (versionGroup.isEmpty) {
      return 'Desconocido';
    }
    // Convierte "black-2-white-2" a "Black 2 White 2"
    return versionGroup
        .split('-')
        .map((word) => word.isEmpty ? '' : widget.formatLabel(word))
        .join(' ');
  }

  /// Carga más movimientos para mostrar (lazy loading)
  void _loadMoreMoves() {
    setState(() {
      _displayedMovesCount += _pageSize;
    });
  }

  /// Reinicia el contador cuando cambian los filtros
  void _resetDisplayCount() {
    setState(() {
      _displayedMovesCount = _pageSize;
    });
  }
  
  /// Calcula cuántos movimientos quedan por cargar
  int _remainingMovesCount(int totalFiltered) {
    return math.max(0, totalFiltered - _displayedMovesCount);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.moves.isEmpty) {
      return const Text('Sin información de movimientos disponible.');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extraer métodos únicos para filtros
    final methods = widget.moves
        .map((move) => move.method)
        .where((method) => method.isNotEmpty)
        .toSet()
        .toList()
      ..sort(
        (a, b) => widget.formatLabel(a).compareTo(widget.formatLabel(b)),
      );

    // Extraer versiones de juego únicas para filtros
    final games = widget.moves
        .where((move) => move.versionGroup != null && move.versionGroup!.isNotEmpty)
        .map((move) => move.versionGroup!)
        .toSet()
        .toList()
      ..sort(
        (a, b) => _formatVersionGroup(a).compareTo(_formatVersionGroup(b)),
      );

    // Filtrar movimientos según criterios seleccionados
    var filteredMoves = widget.moves.where((move) {
      if (_selectedMethod != null && move.method != _selectedMethod) {
        return false;
      }
      if (_selectedGame != null && move.versionGroup != _selectedGame) {
        return false;
      }
      if (_onlyWithLevel && !move.hasLevel) {
        return false;
      }
      return true;
    }).toList();

    // Eliminar duplicados: mantener solo un movimiento por nombre
    // (prioriza el que tiene versionGroup si está disponible)
    final Map<String, PokemonMove> uniqueMoves = {};
    for (final move in filteredMoves) {
      final key = move.name.toLowerCase();
      if (!uniqueMoves.containsKey(key) ||
          (move.versionGroup != null && uniqueMoves[key]!.versionGroup == null)) {
        uniqueMoves[key] = move;
      }
    }
    filteredMoves = uniqueMoves.values.toList()
      ..sort((a, b) {
        final levelA = a.level ?? 999;
        final levelB = b.level ?? 999;
        final levelComparison = levelA.compareTo(levelB);
        if (levelComparison != 0) {
          return levelComparison;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    // Lista de movimientos a mostrar (paginada)
    final displayedMoves = filteredMoves.take(_displayedMovesCount).toList();
    
    // Indica si hay más movimientos para cargar
    final hasMore = _displayedMovesCount < filteredMoves.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección: Filtros por método de aprendizaje
        Text(
          'Método de aprendizaje',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: _selectedMethod == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMethod = null;
                    _resetDisplayCount();
                  });
                }
              },
            ),
            ...methods.map(
              (method) => ChoiceChip(
                label: Text(_formatMethod(method)),
                selected: _selectedMethod == method,
                onSelected: (selected) {
                  setState(() {
                    _selectedMethod = selected ? method : null;
                    _resetDisplayCount();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Sección: Filtros por versión del juego
        if (games.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Versión del juego',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Dropdown para selección de juego
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedGame != null
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: DropdownButton<String?>(
                  value: _selectedGame,
                  hint: const Text('Todas las versiones'),
                  underline: const SizedBox(),
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: _selectedGame != null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'Todas las versiones',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    ...games.map(
                      (game) => DropdownMenuItem<String?>(
                        value: game,
                        child: Text(
                          _formatVersionGroup(game),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (newGame) {
                    setState(() {
                      _selectedGame = newGame;
                      _resetDisplayCount();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        // Filtro adicional: Solo con nivel
        FilterChip(
          label: const Text('Solo movimientos con nivel'),
          selected: _onlyWithLevel,
          onSelected: (selected) {
            setState(() {
              _onlyWithLevel = selected;
              _resetDisplayCount();
            });
          },
          avatar: _onlyWithLevel
              ? Icon(Icons.check_circle, size: 18, color: colorScheme.primary)
              : null,
        ),
        const SizedBox(height: 12),
        if (filteredMoves.isEmpty)
          const Text('No hay movimientos que coincidan con los filtros.')
        else ...[
          Semantics(
            liveRegion: true,
            label: 'Contador de movimientos mostrados',
            child: Text(
              'Mostrando ${displayedMoves.length} de ${filteredMoves.length} movimientos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedMoves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final move = displayedMoves[index];
              final typeKey = move.type?.toLowerCase() ?? '';
              final typeColor =
                  pokemonTypeColors[typeKey] ?? colorScheme.primary;
              final emoji = typeEmojis[typeKey];
              final typeLabel = move.type == null || move.type!.isEmpty
                  ? '—'
                  : widget.formatLabel(move.type!);
              final methodLabel = _formatMethod(move.method);
              final versionLabel = move.versionGroup == null ||
                      move.versionGroup!.isEmpty
                  ? null
                  : _formatVersionGroup(move.versionGroup!);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor.withOpacity(0.28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (emoji != null) ...[
                          Text(emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            _resolveDisplayName(move.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            typeLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        MoveInfoChip(
                          icon: Icons.school_outlined,
                          label: methodLabel,
                        ),
                        MoveInfoChip(
                          icon: Icons.trending_up,
                          label: move.hasLevel
                              ? 'Nivel ${move.level}'
                              : 'Sin nivel definido',
                        ),
                        if (versionLabel != null)
                          MoveInfoChip(
                            icon: Icons.videogame_asset_outlined,
                            label: versionLabel,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // Botón para cargar más movimientos si hay disponibles
          if (hasMore) ...[
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: _loadMoreMoves,
                icon: const Icon(Icons.expand_more),
                label: Text(
                  'Cargar más movimientos (${_remainingMovesCount(filteredMoves.length)} restantes)',
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
