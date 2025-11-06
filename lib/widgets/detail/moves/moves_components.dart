import 'package:flutter/material.dart';

import '../../../models/pokemon_model.dart';
import '../../../theme/pokemon_type_colors.dart';
import '../detail_constants.dart';
import '../detail_helper_widgets.dart';

/// Section displaying Pokemon moves with filtering
class MovesSection extends StatefulWidget {
  const MovesSection({
    super.key,
    required this.moves,
    required this.formatLabel,
  });

  final List<PokemonMove> moves;
  final String Function(String) formatLabel;

  @override
  State<MovesSection> createState() => _MovesSectionState();
}

class _MovesSectionState extends State<MovesSection> {
  String? _selectedMethod;
  bool _onlyWithLevel = false;

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

  @override
  Widget build(BuildContext context) {
    if (widget.moves.isEmpty) {
      return const Text('Sin información de movimientos disponible.');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final methods = widget.moves
        .map((move) => move.method)
        .where((method) => method.isNotEmpty)
        .toSet()
        .toList()
      ..sort(
        (a, b) => widget.formatLabel(a).compareTo(widget.formatLabel(b)),
      );

    final filteredMoves = widget.moves.where((move) {
      if (_selectedMethod != null && move.method != _selectedMethod) {
        return false;
      }
      if (_onlyWithLevel && !move.hasLevel) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final levelA = a.level ?? 999;
        final levelB = b.level ?? 999;
        final levelComparison = levelA.compareTo(levelB);
        if (levelComparison != 0) {
          return levelComparison;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: _selectedMethod == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedMethod = null);
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
                  });
                },
              ),
            ),
            FilterChip(
              label: const Text('Solo movimientos con nivel'),
              selected: _onlyWithLevel,
              onSelected: (selected) {
                setState(() => _onlyWithLevel = selected);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredMoves.isEmpty)
          const Text('No hay movimientos que coincidan con los filtros.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMoves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final move = filteredMoves[index];
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
                  : widget.formatLabel(move.versionGroup!);

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
      ],
    );
  }
}
