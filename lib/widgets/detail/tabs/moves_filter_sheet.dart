import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../models/move_filters.dart';

class MovesFilterSheet extends StatefulWidget {
  const MovesFilterSheet({
    super.key,
    required this.filters,
    required this.availableMethods,
    required this.availableVersionGroups,
    required this.formatLabel,
    required this.formatVersionGroup,
    required this.onApply,
    required this.onReset,
  });

  final MoveFilters filters;
  final List<String> availableMethods;
  final List<String> availableVersionGroups;
  final String Function(String) formatLabel;
  final String Function(String) formatVersionGroup;
  final ValueChanged<MoveFilters> onApply;
  final VoidCallback onReset;

  @override
  State<MovesFilterSheet> createState() => _MovesFilterSheetState();
}

class _MovesFilterSheetState extends State<MovesFilterSheet> {
  late String? _selectedMethod;
  late String? _selectedVersion;
  late bool _onlyWithLevel;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.filters.method;
    _selectedVersion = widget.filters.versionGroup;
    _onlyWithLevel = widget.filters.onlyWithLevel;
  }

  String _formatMethod(AppLocalizations l10n, String method) {
    if (method.toLowerCase() == 'unknown') {
      return l10n.detailMovesFilterMethodUnknown;
    }
    return widget.formatLabel(method);
  }

  void _handleApply() {
    widget.onApply(
      MoveFilters(
        method: _selectedMethod,
        versionGroup: _selectedVersion,
        onlyWithLevel: _onlyWithLevel,
      ),
    );
  }

  void _handleReset() {
    setState(() {
      _selectedMethod = null;
      _selectedVersion = null;
      _onlyWithLevel = false;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final methods = widget.availableMethods;
    final versionGroups = widget.availableVersionGroups;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: viewInsets + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.detailMovesFilterSheetTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.detailMovesFilterMethodTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.detailMovesFilterMethodAll),
                    selected: _selectedMethod == null,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _selectedMethod = null;
                      });
                    },
                  ),
                  ...methods.map(
                    (method) => ChoiceChip(
                      label: Text(_formatMethod(l10n, method)),
                      selected: _selectedMethod == method,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMethod = selected ? method : null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (versionGroups.isNotEmpty) ...[
                Text(
                  l10n.detailMovesFilterVersionTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: _selectedVersion,
                  isDense: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    labelText: l10n.detailMovesFilterVersionLabel,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.detailMovesFilterAllVersions),
                    ),
                    ...versionGroups.map(
                      (version) => DropdownMenuItem<String?>(
                        value: version,
                        child: Text(widget.formatVersionGroup(version)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVersion = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.detailMovesFilterOnlyWithLevel),
                value: _onlyWithLevel,
                onChanged: (value) {
                  setState(() {
                    _onlyWithLevel = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleReset,
                      child: Text(l10n.detailMovesResetButtonLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleApply,
                      child: Text(l10n.commonApply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
