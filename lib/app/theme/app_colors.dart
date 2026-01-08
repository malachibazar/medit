import 'package:flutter/cupertino.dart';

/// Semantic color system following macOS Sequoia design guidelines.
/// Colors automatically adapt to light/dark mode when used with AppTheme helpers.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ============================================
  // BACKGROUNDS
  // ============================================

  // Dark mode backgrounds (elevated surface pattern - not pure black)
  static const darkWindowBg = Color(0xFF1C1C1E);
  static const darkSidebarBg = Color(0xFF252527);
  static const darkContentBg = Color(0xFF2C2C2E);
  static const darkEditorBg = Color(0xFF1E1E1E);
  static const darkElevated = Color(0xFF3A3A3C);
  static const darkHover = Color(0xFF3A3A3C);
  static const darkSelected = Color(0xFF464649);

  // Light mode backgrounds
  static const lightWindowBg = Color(0xFFF5F5F7);
  static const lightSidebarBg = Color(0xFFE8E8ED);
  static const lightContentBg = Color(0xFFFFFFFF);
  static const lightEditorBg = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFFFFFFF);
  static const lightHover = Color(0xFFE5E5EA);
  static const lightSelected = Color(0xFFD1D1D6);

  // ============================================
  // ACCENT COLORS (macOS system colors)
  // ============================================

  static const accent = Color(0xFF007AFF); // Primary blue
  static const accentLight = Color(0xFF5AC8FA); // Light blue
  static const purple = Color(0xFF5856D6); // Secondary
  static const green = Color(0xFF34C759); // Success
  static const orange = Color(0xFFFF9500); // Warning
  static const red = Color(0xFFFF3B30); // Destructive
  static const pink = Color(0xFFFF2D55); // Accent alt
  static const teal = Color(0xFF5AC8FA); // Info
  static const yellow = Color(0xFFFFCC00); // Highlight
  static const indigo = Color(0xFF5856D6); // Alternative accent

  // ============================================
  // TEXT COLORS
  // ============================================

  // Dark mode text
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E93);
  static const darkTextTertiary = Color(0xFF636366);
  static const darkTextQuaternary = Color(0xFF48484A);
  static const darkTextPlaceholder = Color(0xFF636366);

  // Light mode text
  static const lightTextPrimary = Color(0xFF000000);
  static const lightTextSecondary = Color(0xFF6E6E73);
  static const lightTextTertiary = Color(0xFF8E8E93);
  static const lightTextQuaternary = Color(0xFFAEAEB2);
  static const lightTextPlaceholder = Color(0xFF8E8E93);

  // ============================================
  // BORDERS & SEPARATORS
  // ============================================

  static const darkSeparator = Color(0xFF38383A);
  static const darkBorder = Color(0xFF48484A);
  static const lightSeparator = Color(0xFFD1D1D6);
  static const lightBorder = Color(0xFFC6C6C8);

  // ============================================
  // FOLDER COLORS (for user selection)
  // ============================================

  static const List<Color> folderColors = [
    Color(0xFFFF3B30), // Red
    Color(0xFFFF9500), // Orange
    Color(0xFFFFCC00), // Yellow
    Color(0xFF34C759), // Green
    Color(0xFF5AC8FA), // Teal
    Color(0xFF007AFF), // Blue
    Color(0xFF5856D6), // Purple
    Color(0xFFAF52DE), // Magenta
    Color(0xFFFF2D55), // Pink
    Color(0xFF8E8E93), // Gray
  ];

  static const List<String> folderColorNames = [
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Teal',
    'Blue',
    'Purple',
    'Magenta',
    'Pink',
    'Gray',
  ];

  /// Get folder color by hex string, returns default blue if not found
  static Color getFolderColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return folderColors[5]; // Default to blue
    }
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      return folderColors[5];
    }
  }

  /// Convert color to hex string for storage
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // ============================================
  // SPECIAL COLORS
  // ============================================

  // Toolbar button colors
  static const darkToolbarBg = Color(0xFF2C2C2E);
  static const lightToolbarBg = Color(0xFFF2F2F7);
  static const darkToolbarButton = Color(0xFF3A3A3C);
  static const lightToolbarButton = Color(0xFFE5E5EA);
  static const darkToolbarButtonHover = Color(0xFF48484A);
  static const lightToolbarButtonHover = Color(0xFFD1D1D6);

  // Status bar colors
  static const saveStatusSaved = green;
  static const saveStatusSaving = orange;
  static const saveStatusUnsaved = orange;

  // Selection highlight
  static const selectionHighlight = Color(0x33007AFF); // Blue with 20% opacity

  // Focus ring
  static const focusRing = accent;
}
