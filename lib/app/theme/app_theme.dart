import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// Centralized theme configuration with helper methods for consistent styling.
/// Use these helpers throughout the app to ensure proper light/dark mode support.
class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ============================================
  // THEME DETECTION
  // ============================================

  /// Check if the current context is in dark mode
  static bool isDark(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
  }

  // ============================================
  // BACKGROUND COLORS
  // ============================================

  static Color windowBg(BuildContext context) =>
      isDark(context) ? AppColors.darkWindowBg : AppColors.lightWindowBg;

  static Color sidebarBg(BuildContext context) =>
      isDark(context) ? AppColors.darkSidebarBg : AppColors.lightSidebarBg;

  static Color contentBg(BuildContext context) =>
      isDark(context) ? AppColors.darkContentBg : AppColors.lightContentBg;

  static Color editorBg(BuildContext context) =>
      isDark(context) ? AppColors.darkEditorBg : AppColors.lightEditorBg;

  static Color elevated(BuildContext context) =>
      isDark(context) ? AppColors.darkElevated : AppColors.lightElevated;

  static Color hover(BuildContext context) =>
      isDark(context) ? AppColors.darkHover : AppColors.lightHover;

  static Color selected(BuildContext context) =>
      isDark(context) ? AppColors.darkSelected : AppColors.lightSelected;

  // ============================================
  // TEXT COLORS
  // ============================================

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context)
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;

  static Color textTertiary(BuildContext context) =>
      isDark(context)
          ? AppColors.darkTextTertiary
          : AppColors.lightTextTertiary;

  static Color textQuaternary(BuildContext context) =>
      isDark(context)
          ? AppColors.darkTextQuaternary
          : AppColors.lightTextQuaternary;

  static Color textPlaceholder(BuildContext context) =>
      isDark(context)
          ? AppColors.darkTextPlaceholder
          : AppColors.lightTextPlaceholder;

  // ============================================
  // BORDER & SEPARATOR COLORS
  // ============================================

  static Color separator(BuildContext context) =>
      isDark(context) ? AppColors.darkSeparator : AppColors.lightSeparator;

  static Color border(BuildContext context) =>
      isDark(context) ? AppColors.darkBorder : AppColors.lightBorder;

  // ============================================
  // TOOLBAR COLORS
  // ============================================

  static Color toolbarBg(BuildContext context) =>
      isDark(context) ? AppColors.darkToolbarBg : AppColors.lightToolbarBg;

  static Color toolbarButton(BuildContext context) =>
      isDark(context)
          ? AppColors.darkToolbarButton
          : AppColors.lightToolbarButton;

  static Color toolbarButtonHover(BuildContext context) =>
      isDark(context)
          ? AppColors.darkToolbarButtonHover
          : AppColors.lightToolbarButtonHover;

  // ============================================
  // TEXT STYLES
  // ============================================

  /// Large title style (e.g., screen titles)
  static TextStyle largeTitle(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textPrimary(context),
    letterSpacing: -0.5,
  );

  /// Title style (e.g., navigation bar)
  static TextStyle title(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
  );

  /// Headline style (e.g., section headers)
  static TextStyle headline(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
  );

  /// Body style (e.g., main content)
  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textPrimary(context),
    height: 1.4,
  );

  /// Callout style (e.g., note previews)
  static TextStyle callout(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textSecondary(context),
    height: 1.3,
  );

  /// Subhead style (e.g., sidebar items)
  static TextStyle subhead(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textPrimary(context),
  );

  /// Footnote style (e.g., timestamps)
  static TextStyle footnote(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: textTertiary(context),
  );

  /// Caption style (e.g., labels)
  static TextStyle caption(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textTertiary(context),
    letterSpacing: 0.5,
  );

  /// Section header style (e.g., "FOLDERS" in sidebar)
  static TextStyle sectionHeader(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textTertiary(context),
    letterSpacing: 0.5,
  );

  /// Note title style in cards
  static TextStyle noteTitle(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary(context),
  );

  /// Note preview style in cards
  static TextStyle notePreview(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary(context),
    height: 1.3,
  );

  /// Editor title style
  static TextStyle editorTitle(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary(context),
  );

  /// Editor body style
  static TextStyle editorBody(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textPrimary(context),
    height: 1.6,
  );

  /// Monospace style for code
  static TextStyle monospace(BuildContext context) => TextStyle(
    fontFamily: 'SF Mono',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textPrimary(context),
  );

  /// Placeholder style
  static TextStyle placeholder(BuildContext context) => TextStyle(
    fontFamily: '.AppleSystemUIFont',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textPlaceholder(context),
  );

  // ============================================
  // DECORATIONS
  // ============================================

  /// Card decoration for note cards
  static BoxDecoration cardDecoration(
    BuildContext context, {
    bool isSelected = false,
    bool isHovered = false,
  }) {
    Color bgColor;
    if (isSelected) {
      bgColor = selected(context);
    } else if (isHovered) {
      bgColor = hover(context);
    } else {
      bgColor = contentBg(context);
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      border:
          isSelected
              ? Border(left: BorderSide(color: AppColors.accent, width: 3))
              : null,
    );
  }

  /// Sidebar item decoration
  static BoxDecoration sidebarItemDecoration(
    BuildContext context, {
    bool isSelected = false,
    bool isHovered = false,
  }) {
    Color? bgColor;
    if (isSelected) {
      bgColor = AppColors.accent.withOpacity(0.15);
    } else if (isHovered) {
      bgColor = hover(context);
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
    );
  }

  /// Toolbar button decoration
  static BoxDecoration toolbarButtonDecoration(
    BuildContext context, {
    bool isActive = false,
    bool isHovered = false,
  }) {
    Color? bgColor;
    if (isActive) {
      bgColor = AppColors.accent.withOpacity(0.2);
    } else if (isHovered) {
      bgColor = toolbarButtonHover(context);
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
    );
  }

  /// Input field decoration
  static BoxDecoration inputDecoration(BuildContext context) {
    return BoxDecoration(
      color: editorBg(context),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: border(context), width: 0.5),
    );
  }

  /// Panel border (for column separators)
  static Border panelBorder(BuildContext context, {bool right = true}) {
    return Border(
      right:
          right
              ? BorderSide(color: separator(context), width: 1)
              : BorderSide.none,
    );
  }

  // ============================================
  // SHADOWS
  // ============================================

  /// Subtle shadow for elevated elements
  static List<BoxShadow> subtleShadow(BuildContext context) {
    if (isDark(context)) {
      return []; // No shadows in dark mode
    }
    return [
      BoxShadow(
        color: CupertinoColors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Card shadow
  static List<BoxShadow> cardShadow(BuildContext context) {
    if (isDark(context)) {
      return [];
    }
    return [
      BoxShadow(
        color: CupertinoColors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 350);

  // ============================================
  // SPACING
  // ============================================

  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  // ============================================
  // PANEL WIDTHS
  // ============================================

  static const double sidebarDefaultWidth = 200;
  static const double sidebarMinWidth = 160;
  static const double sidebarMaxWidth = 280;

  static const double notesListDefaultWidth = 280;
  static const double notesListMinWidth = 200;
  static const double notesListMaxWidth = 400;

  static const double editorMinWidth = 400;

  // ============================================
  // BORDER RADIUS
  // ============================================

  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusXLarge = 16;
}
