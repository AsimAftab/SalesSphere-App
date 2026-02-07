import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'utilities.model.freezed.dart';

// ============================================================================
// UI Models
// ============================================================================

/// Represents a single utility card item on the screen
@freezed
abstract class UtilityItem with _$UtilityItem {
  const factory UtilityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String routePath,
  }) = _UtilityItem;
}
