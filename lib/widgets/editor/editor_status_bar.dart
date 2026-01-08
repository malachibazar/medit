import 'package:flutter/cupertino.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import 'note_editor.dart';

/// Status bar showing word count, save status, and mode indicator
class EditorStatusBar extends StatelessWidget {
  final int wordCount;
  final int charCount;
  final SaveStatus saveStatus;
  final DateTime? lastSaved;
  final bool isPreviewMode;
  final VoidCallback onTogglePreview;

  const EditorStatusBar({
    super.key,
    required this.wordCount,
    required this.charCount,
    required this.saveStatus,
    this.lastSaved,
    required this.isPreviewMode,
    required this.onTogglePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.toolbarBg(context),
        border: Border(
          top: BorderSide(color: AppTheme.separator(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Word and character count
          Text(
            '$wordCount ${wordCount == 1 ? 'word' : 'words'}',
            style: AppTheme.footnote(context),
          ),
          _buildDot(context),
          Text(
            '$charCount ${charCount == 1 ? 'character' : 'characters'}',
            style: AppTheme.footnote(context),
          ),

          const Spacer(),

          // Save status
          _buildSaveStatus(context),

          _buildDot(context),

          // Mode indicator
          Text(
            isPreviewMode ? 'Preview' : 'Edit',
            style: AppTheme.footnote(
              context,
            ).copyWith(fontWeight: FontWeight.w500),
          ),

          _buildDot(context),

          // Toggle hint
          GestureDetector(
            onTap: onTogglePreview,
            child: Text(
              isPreviewMode ? '↵ Edit' : '⌘↵ Preview',
              style: AppTheme.footnote(
                context,
              ).copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('•', style: AppTheme.footnote(context)),
    );
  }

  Widget _buildSaveStatus(BuildContext context) {
    IconData icon;
    Color color;
    String text;

    switch (saveStatus) {
      case SaveStatus.saved:
        icon = CupertinoIcons.checkmark_circle_fill;
        color = AppColors.green;
        text = _formatSavedTime();
        break;
      case SaveStatus.saving:
        icon = CupertinoIcons.arrow_2_circlepath;
        color = AppColors.orange;
        text = 'Saving...';
        break;
      case SaveStatus.unsaved:
        icon = CupertinoIcons.circle_fill;
        color = AppColors.orange;
        text = 'Unsaved';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: AppTheme.footnote(context).copyWith(color: color)),
      ],
    );
  }

  String _formatSavedTime() {
    if (lastSaved == null) return 'Saved';

    final diff = DateTime.now().difference(lastSaved!);

    if (diff.inSeconds < 5) {
      return 'Saved just now';
    } else if (diff.inSeconds < 60) {
      return 'Saved ${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return 'Saved ${diff.inMinutes}m ago';
    } else {
      return 'Saved ${diff.inHours}h ago';
    }
  }
}
