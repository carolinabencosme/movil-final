import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/move_filters.dart';
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
///
/// Los filtros activos se reciben desde la pestaña de movimientos mediante el modelo
/// [MoveFilters], permitiendo desacoplar la lógica de filtrado de la interfaz que los
/// modifica.
class MovesSection extends StatefulWidget {
  const MovesSection({
    super.key,
    required this.moves,
    required this.formatLabel,
    required this.filters,
    this.onCountsChanged,
  });

  /// Lista completa de movimientos del Pokémon desde la API
  final List<PokemonMove> moves;

  /// Función para formatear etiquetas de texto (capitalización)
  final String Function(String) formatLabel;

  /// Filtros activos a aplicar sobre la lista
  final MoveFilters filters;

  /// Callback opcional para informar cuántos movimientos se están mostrando
  final void Function(int visible, int total)? onCountsChanged;

  @override
  State<MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<MovesSection> {
  /// Número de movimientos a mostrar inicialmente y por cada carga
  static const int _pageSize = 15;

  /// Contador de movimientos actualmente visibles
  int _displayedMovesCount = _pageSize;

  int? _lastReportedVisible;
  int? _lastReportedTotal;

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
        .where((word) => word.isNotEmpty)
        .map(widget.formatLabel)
        .join(' ');
  }

  /// Carga más movimientos para mostrar (lazy loading)
  void _loadMoreMoves() {
    setState(() {
      _displayedMovesCount += _pageSize;
    });
  }

  /// Calcula cuántos movimientos quedan por cargar
  int _remainingMovesCount(int totalFiltered) {
    return math.max(0, totalFiltered - _displayedMovesCount);
  }

  /// Elimina movimientos duplicados basándose en el nombre
  /// 
  /// Mantiene solo un movimiento por nombre único. Si hay múltiples movimientos
  /// con el mismo nombre, prioriza el que tiene `versionGroup` definido.
  /// 
  /// Ejemplo: Si "Tackle" aparece en 3 versiones diferentes, solo se mantiene una entrada.
  /// 
  /// [moves] Lista de movimientos a deduplicar
  /// Retorna una lista de movimientos sin duplicados
  List<PokemonMove> _deduplicateMoves(List<PokemonMove> moves) {
    final Map<String, PokemonMove> uniqueMoves = {};

    for (final move in moves) {
      final key = move.name.toLowerCase();
      
      // Si no existe o el nuevo tiene versionGroup y el anterior no
      if (!uniqueMoves.containsKey(key) ||
          (move.versionGroup != null && uniqueMoves[key]!.versionGroup == null)) {
        uniqueMoves[key] = move;
      }
    }
    
    return uniqueMoves.values.toList();
  }

  void _notifyCounts(int visible, int total) {
    if (widget.onCountsChanged == null) return;
    if (_lastReportedVisible == visible && _lastReportedTotal == total) {
      return;
    }
    _lastReportedVisible = visible;
    _lastReportedTotal = total;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onCountsChanged?.call(visible, total);
    });
  }

  void _resetPagination() {
    _displayedMovesCount = _pageSize;
    _lastReportedVisible = null;
    _lastReportedTotal = null;
  }

  @override
  void didUpdateWidget(covariant MovesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters ||
        oldWidget.moves != widget.moves) {
      _resetPagination();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.moves.isEmpty) {
      return const Text('Sin información de movimientos disponible.');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filtrar movimientos según criterios seleccionados
    var filteredMoves = widget.moves.where((move) {
      if (widget.filters.method != null &&
          move.method != widget.filters.method) {
        return false;
      }
      if (widget.filters.versionGroup != null &&
          move.versionGroup != widget.filters.versionGroup) {
        return false;
      }
      if (widget.filters.onlyWithLevel && !move.hasLevel) {
        return false;
      }
      return true;
    }).toList();

    // Aplicar deduplicación
    filteredMoves = _deduplicateMoves(filteredMoves)
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

    _notifyCounts(displayedMoves.length, filteredMoves.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredMoves.isEmpty)
          const Text('No hay movimientos que coincidan con los filtros.')
        else ...[
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
