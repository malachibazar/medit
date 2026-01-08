import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';

/// Floating/sticky markdown formatting toolbar
class FormattingToolbar extends StatelessWidget {
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onStrikethrough;
  final VoidCallback onHeading1;
  final VoidCallback onHeading2;
  final VoidCallback onHeading3;
  final VoidCallback onBulletList;
  final VoidCallback onNumberedList;
  final VoidCallback onChecklist;
  final VoidCallback onBlockquote;
  final VoidCallback onInlineCode;
  final VoidCallback onCodeBlock;
  final VoidCallback onLink;
  final VoidCallback onImage;
  final VoidCallback onTogglePreview;
  final bool isPreviewMode;

  const FormattingToolbar({
    super.key,
    required this.onBold,
    required this.onItalic,
    required this.onStrikethrough,
    required this.onHeading1,
    required this.onHeading2,
    required this.onHeading3,
    required this.onBulletList,
    required this.onNumberedList,
    required this.onChecklist,
    required this.onBlockquote,
    required this.onInlineCode,
    required this.onCodeBlock,
    required this.onLink,
    required this.onImage,
    required this.onTogglePreview,
    required this.isPreviewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.toolbarBg(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.separator(context), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Text formatting group
            _ToolbarButton(
              icon: 'B',
              tooltip: 'Bold (⌘B)',
              isBold: true,
              onPressed: onBold,
            ),
            _ToolbarButton(
              icon: 'I',
              tooltip: 'Italic (⌘I)',
              isItalic: true,
              onPressed: onItalic,
            ),
            _ToolbarButton(
              icon: 'S',
              tooltip: 'Strikethrough (⌘⇧S)',
              isStrikethrough: true,
              onPressed: onStrikethrough,
            ),

            _buildDivider(context),

            // Headings group
            _ToolbarButton(
              label: 'H1',
              tooltip: 'Heading 1 (⌘1)',
              onPressed: onHeading1,
            ),
            _ToolbarButton(
              label: 'H2',
              tooltip: 'Heading 2 (⌘2)',
              onPressed: onHeading2,
            ),
            _ToolbarButton(
              label: 'H3',
              tooltip: 'Heading 3 (⌘3)',
              onPressed: onHeading3,
            ),

            _buildDivider(context),

            // Lists group
            _ToolbarButton(
              iconData: CupertinoIcons.list_bullet,
              tooltip: 'Bullet List (⌘⇧U)',
              onPressed: onBulletList,
            ),
            _ToolbarButton(
              iconData: CupertinoIcons.list_number,
              tooltip: 'Numbered List (⌘⇧O)',
              onPressed: onNumberedList,
            ),
            _ToolbarButton(
              iconData: CupertinoIcons.checkmark_square,
              tooltip: 'Checklist (⌘⇧L)',
              onPressed: onChecklist,
            ),

            _buildDivider(context),

            // Quote and code group
            _ToolbarButton(
              iconData: CupertinoIcons.text_quote,
              tooltip: 'Blockquote (⌘⇧.)',
              onPressed: onBlockquote,
            ),
            _ToolbarButton(
              label: '</>',
              tooltip: 'Inline Code (⌘`)',
              isMonospace: true,
              onPressed: onInlineCode,
            ),
            _ToolbarButton(
              iconData: CupertinoIcons.chevron_left_slash_chevron_right,
              tooltip: 'Code Block (⌘⇧C)',
              onPressed: onCodeBlock,
            ),

            _buildDivider(context),

            // Insert group
            _ToolbarButton(
              iconData: CupertinoIcons.link,
              tooltip: 'Insert Link (⌘K)',
              onPressed: onLink,
            ),
            _ToolbarButton(
              iconData: CupertinoIcons.photo,
              tooltip: 'Insert Image (⌘⇧I)',
              onPressed: onImage,
            ),

            _buildDivider(context),

            // Preview toggle
            _ToolbarButton(
              iconData: CupertinoIcons.eye,
              tooltip: 'Preview (⌘↵)',
              onPressed: onTogglePreview,
              isAccent: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppTheme.separator(context),
    );
  }
}

/// Individual toolbar button with hover state
class _ToolbarButton extends StatefulWidget {
  final String? icon;
  final String? label;
  final IconData? iconData;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isBold;
  final bool isItalic;
  final bool isStrikethrough;
  final bool isMonospace;
  final bool isAccent;

  const _ToolbarButton({
    this.icon,
    this.label,
    this.iconData,
    required this.tooltip,
    required this.onPressed,
    this.isBold = false,
    this.isItalic = false,
    this.isStrikethrough = false,
    this.isMonospace = false,
    this.isAccent = false,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: AppTheme.toolbarButtonDecoration(
              context,
              isHovered: _isHovered,
              isActive: widget.isAccent,
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final color =
        widget.isAccent ? AppColors.accent : AppTheme.textPrimary(context);

    if (widget.iconData != null) {
      return Icon(widget.iconData, size: 18, color: color);
    }

    if (widget.icon != null || widget.label != null) {
      final text = widget.icon ?? widget.label!;
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: widget.isBold ? FontWeight.bold : FontWeight.w500,
          fontStyle: widget.isItalic ? FontStyle.italic : FontStyle.normal,
          decoration:
              widget.isStrikethrough
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
          fontFamily: widget.isMonospace ? 'SF Mono' : null,
          color: color,
        ),
      );
    }

    return const SizedBox();
  }
}
