import 'package:flutter/cupertino.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';

/// Enhanced note card widget with hover states and favorite toggle
class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isSelected;
  final bool isHovered;
  final bool isFocused;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.isFavorite,
    this.isSelected = false,
    this.isHovered = false,
    this.isFocused = false,
    this.onToggleFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTheme.fastAnimation,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: _buildDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.isEmpty ? 'Untitled' : title,
                    style: AppTheme.noteTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Actions: show on hover
                if (isHovered || isSelected) ...[
                  // Delete button
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        CupertinoIcons.trash,
                        size: 14,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Favorite star: visible when favorited OR hovered
                if (isFavorite || isHovered)
                  GestureDetector(
                    onTap: onToggleFavorite,
                    child: AnimatedOpacity(
                      duration: AppTheme.fastAnimation,
                      opacity: isFavorite ? 1.0 : 0.5,
                      child: Icon(
                        isFavorite
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        size: 16,
                        color:
                            isFavorite
                                ? AppColors.yellow
                                : AppTheme.textTertiary(context),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Preview
            Text(
              _getPreviewText(),
              style: AppTheme.notePreview(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Timestamp
            Text(
              _formatRelativeTime(updatedAt),
              style: AppTheme.footnote(context),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    Color bgColor;
    Border? border;

    if (isSelected) {
      bgColor = AppTheme.selected(context);
      border = Border(left: BorderSide(color: AppColors.accent, width: 3));
    } else if (isHovered) {
      bgColor = AppTheme.hover(context);
    } else {
      bgColor = AppTheme.contentBg(context);
    }

    return BoxDecoration(
      color: bgColor,
      border: border,
      borderRadius: BorderRadius.circular(8),
    );
  }

  String _getPreviewText() {
    if (content.isEmpty) return 'No content';

    // Strip markdown syntax for preview
    final preview =
        content
            .replaceAll(RegExp(r'#{1,6}\s'), '') // Remove headings
            .replaceAll(RegExp(r'\*\*|\*|__|\~\~|`'), '') // Remove formatting
            .replaceAll(
              RegExp(r'\!\[.*?\]\(.*?\)'),
              '[Image]',
            ) // Replace images
            .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '[Link]') // Replace links
            .replaceAll(RegExp(r'>\s.*'), '') // Remove blockquotes
            .replaceAll(
              RegExp(r'```[\s\S]*?```'),
              '[Code]',
            ) // Remove code blocks
            .replaceAll(RegExp(r'\n+'), ' ') // Collapse newlines
            .trim();

    return preview.isEmpty ? 'No content' : preview;
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
