import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';

/// Enhanced markdown preview widget with macOS-style styling
/// Uses MarkdownBody instead of Markdown to avoid nested scrollable issues
class MarkdownView extends StatelessWidget {
  final String data;
  final ScrollController? scrollController;

  const MarkdownView({super.key, required this.data, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDark(context);

    // Use MarkdownBody instead of Markdown to avoid unbounded height issues
    // when nested inside SingleChildScrollView
    return MarkdownBody(
      data: data,
      selectable: true,
      softLineBreak: true,
      styleSheet: _buildStyleSheet(context, isDarkMode),
    );
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context, bool isDarkMode) {
    final textColor = AppTheme.textPrimary(context);
    final secondaryColor = AppTheme.textSecondary(context);
    final codeBackground =
        isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5);
    final blockquoteBorder = AppColors.accent;

    return MarkdownStyleSheet(
      // Headings
      h1: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      h1Padding: const EdgeInsets.only(bottom: 12, top: 24),

      h2: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      h2Padding: const EdgeInsets.only(bottom: 10, top: 20),

      h3: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(bottom: 8, top: 16),

      h4: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      h4Padding: const EdgeInsets.only(bottom: 6, top: 14),

      h5: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      h5Padding: const EdgeInsets.only(bottom: 4, top: 12),

      h6: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        height: 1.3,
      ),
      h6Padding: const EdgeInsets.only(bottom: 4, top: 10),

      // Paragraph
      p: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.6,
      ),
      pPadding: const EdgeInsets.only(bottom: 12),

      // Strong and emphasis
      strong: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      em: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      del: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        decoration: TextDecoration.lineThrough,
        color: secondaryColor,
      ),

      // Code
      code: TextStyle(
        fontFamily: 'SF Mono',
        fontSize: 13,
        color: isDarkMode ? AppColors.accentLight : AppColors.accent,
        backgroundColor: codeBackground,
      ),
      codeblockPadding: const EdgeInsets.all(16),
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border(context), width: 1),
      ),

      // Blockquote
      blockquote: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 15,
        fontStyle: FontStyle.italic,
        color: secondaryColor,
        height: 1.6,
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: blockquoteBorder, width: 4)),
      ),

      // Links
      a: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        color: AppColors.accent,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.accent.withValues(alpha: 0.5),
      ),

      // Lists
      listBullet: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 15,
        color: textColor,
      ),
      listIndent: 24,
      listBulletPadding: const EdgeInsets.only(right: 8),

      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.separator(context), width: 1),
        ),
      ),

      // Table
      tableHead: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: textColor,
      ),
      tableBody: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        fontSize: 14,
        color: textColor,
      ),
      tableBorder: TableBorder.all(color: AppTheme.border(context), width: 1),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      // Checkbox (for task lists)
      checkbox: TextStyle(
        fontFamily: '.AppleSystemUIFont',
        color: AppColors.accent,
      ),

      // Image
      img: TextStyle(fontFamily: '.AppleSystemUIFont', color: secondaryColor),
    );
  }
}
