import 'package:flutter/foundation.dart';

/// Immutable model that stores filtering options for Pokémon moves.
@immutable
class MoveFilters {
  const MoveFilters({
    this.method,
    this.versionGroup,
    this.onlyWithLevel = false,
  });

  /// Move learning method (e.g., level-up, machine, tutor).
  final String? method;

  /// Version group that the move belongs to.
  final String? versionGroup;

  /// Whether the list should only include moves that specify a level.
  final bool onlyWithLevel;

  /// Convenience constructor for the default (unfiltered) state.
  const MoveFilters.initial()
      : method = null,
        versionGroup = null,
        onlyWithLevel = false;

  static const Object _sentinel = Object();

  /// Returns a copy of this filter configuration overriding the given values.
  ///
  /// Passing `null` explicitly to [method] or [versionGroup] will override the
  /// corresponding property with `null`.
  MoveFilters copyWith({
    Object? method = _sentinel,
    Object? versionGroup = _sentinel,
    bool? onlyWithLevel,
  }) {
    return MoveFilters(
      method: method == _sentinel ? this.method : method as String?,
      versionGroup:
          versionGroup == _sentinel ? this.versionGroup : versionGroup as String?,
      onlyWithLevel: onlyWithLevel ?? this.onlyWithLevel,
    );
  }

  /// Returns whether the filters are in their default (unfiltered) state.
  bool get isDefault =>
      method == null && versionGroup == null && !onlyWithLevel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoveFilters &&
        other.method == method &&
        other.versionGroup == versionGroup &&
        other.onlyWithLevel == onlyWithLevel;
  }

  @override
  int get hashCode => Object.hash(method, versionGroup, onlyWithLevel);

  @override
  String toString() =>
      'MoveFilters(method: $method, versionGroup: $versionGroup, onlyWithLevel: $onlyWithLevel)';
}
