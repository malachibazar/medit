import 'package:flutter/cupertino.dart';
import '../../app/theme/app_theme.dart';

/// Dialog showing all keyboard shortcuts organized by category
class ShortcutsHelpDialog extends StatelessWidget {
  const ShortcutsHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.elevated(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.separator(context),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.keyboard,
                    color: AppTheme.textPrimary(context),
                  ),
                  const SizedBox(width: 12),
                  Text('Keyboard Shortcuts', style: AppTheme.title(context)),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 20,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            // Shortcuts content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(context, 'General', [
                            ('New Note', '⌘N'),
                            ('Command Palette', '⌘⇧P'),
                            ('Find in Note', '⌘F'),
                            ('Save', '⌘S'),
                            ('Delete Note', '⌘⌫'),
                          ]),
                          const SizedBox(height: 24),
                          _buildSection(context, 'Navigation', [
                            ('Toggle Sidebar', '⌘\\'),
                            ('All Notes', '⌘⇧1'),
                            ('Favorites', '⌘⇧2'),
                            ('Recents', '⌘⇧3'),
                            ('Toggle Preview', '⌘↵'),
                            ('Close / Back', 'Esc'),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(context, 'Formatting', [
                            ('Bold', '⌘B'),
                            ('Italic', '⌘I'),
                            ('Strikethrough', '⌘⇧S'),
                            ('Heading 1', '⌘1'),
                            ('Heading 2', '⌘2'),
                            ('Heading 3', '⌘3'),
                            ('Insert Link', '⌘K'),
                            ('Insert Image', '⌘⇧I'),
                            ('Bullet List', '⌘⇧U'),
                            ('Numbered List', '⌘⇧O'),
                            ('Checklist', '⌘⇧L'),
                            ('Blockquote', '⌘⇧.'),
                            ('Inline Code', '⌘`'),
                            ('Code Block', '⌘⇧C'),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.sidebarBg(context),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  'Press Esc or click outside to close',
                  style: AppTheme.footnote(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<(String, String)> shortcuts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTheme.sectionHeader(context)),
        const SizedBox(height: 4),
        Container(height: 1, width: 60, color: AppTheme.separator(context)),
        const SizedBox(height: 12),
        ...shortcuts.map((s) => _buildShortcutRow(context, s.$1, s.$2)),
      ],
    );
  }

  Widget _buildShortcutRow(
    BuildContext context,
    String action,
    String shortcut,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(action, style: AppTheme.body(context))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.toolbarButton(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: AppTheme.footnote(
                context,
              ).copyWith(fontFamily: 'SF Mono', fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
