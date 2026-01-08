import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import '../editor/note_editor.dart';

/// Command palette configuration and dialog
class CommandPaletteConfig {
  /// Show the command palette dialog
  static void show({
    required BuildContext context,
    required VoidCallback onNewNote,
    required VoidCallback onToggleSidebar,
    required VoidCallback onTogglePreview,
    required VoidCallback onShowShortcuts,
    required VoidCallback onGoToAllNotes,
    required VoidCallback onGoToFavorites,
    required VoidCallback onGoToRecents,
    required VoidCallback onDeleteNote,
    required VoidCallback onSave,
    GlobalKey<NoteEditorState>? editorKey,
  }) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => _CommandPaletteDialog(
            onNewNote: onNewNote,
            onToggleSidebar: onToggleSidebar,
            onTogglePreview: onTogglePreview,
            onShowShortcuts: onShowShortcuts,
            onGoToAllNotes: onGoToAllNotes,
            onGoToFavorites: onGoToFavorites,
            onGoToRecents: onGoToRecents,
            onDeleteNote: onDeleteNote,
            onSave: onSave,
            editorKey: editorKey,
          ),
    );
  }
}

class _CommandPaletteDialog extends StatefulWidget {
  final VoidCallback onNewNote;
  final VoidCallback onToggleSidebar;
  final VoidCallback onTogglePreview;
  final VoidCallback onShowShortcuts;
  final VoidCallback onGoToAllNotes;
  final VoidCallback onGoToFavorites;
  final VoidCallback onGoToRecents;
  final VoidCallback onDeleteNote;
  final VoidCallback onSave;
  final GlobalKey<NoteEditorState>? editorKey;

  const _CommandPaletteDialog({
    required this.onNewNote,
    required this.onToggleSidebar,
    required this.onTogglePreview,
    required this.onShowShortcuts,
    required this.onGoToAllNotes,
    required this.onGoToFavorites,
    required this.onGoToRecents,
    required this.onDeleteNote,
    required this.onSave,
    this.editorKey,
  });

  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;
  String _query = '';

  late List<_CommandItem> _allCommands;
  List<_CommandItem> _filteredCommands = [];

  @override
  void initState() {
    super.initState();
    _initCommands();
    _filteredCommands = _allCommands;
    _searchFocusNode.requestFocus();
  }

  void _initCommands() {
    _allCommands = [
      // Navigation
      _CommandItem(
        label: 'New Note',
        shortcut: '⌘N',
        icon: CupertinoIcons.add,
        category: 'Navigation',
        action: () {
          Navigator.pop(context);
          widget.onNewNote();
        },
      ),
      _CommandItem(
        label: 'Go to All Notes',
        shortcut: '⌘⇧1',
        icon: CupertinoIcons.doc_text,
        category: 'Navigation',
        action: () {
          Navigator.pop(context);
          widget.onGoToAllNotes();
        },
      ),
      _CommandItem(
        label: 'Go to Favorites',
        shortcut: '⌘⇧2',
        icon: CupertinoIcons.star,
        category: 'Navigation',
        action: () {
          Navigator.pop(context);
          widget.onGoToFavorites();
        },
      ),
      _CommandItem(
        label: 'Go to Recents',
        shortcut: '⌘⇧3',
        icon: CupertinoIcons.clock,
        category: 'Navigation',
        action: () {
          Navigator.pop(context);
          widget.onGoToRecents();
        },
      ),
      _CommandItem(
        label: 'Toggle Sidebar',
        shortcut: '⌘\\',
        icon: CupertinoIcons.sidebar_left,
        category: 'Navigation',
        action: () {
          Navigator.pop(context);
          widget.onToggleSidebar();
        },
      ),

      // Editor
      _CommandItem(
        label: 'Toggle Preview',
        shortcut: '⌘↵',
        icon: CupertinoIcons.eye,
        category: 'Editor',
        action: () {
          Navigator.pop(context);
          widget.onTogglePreview();
        },
      ),
      _CommandItem(
        label: 'Save Note',
        shortcut: '⌘S',
        icon: CupertinoIcons.floppy_disk,
        category: 'Editor',
        action: () {
          Navigator.pop(context);
          widget.onSave();
        },
      ),
      _CommandItem(
        label: 'Delete Note',
        shortcut: '⌘⌫',
        icon: CupertinoIcons.trash,
        category: 'Editor',
        isDestructive: true,
        action: () {
          Navigator.pop(context);
          widget.onDeleteNote();
        },
      ),

      // Formatting
      _CommandItem(
        label: 'Bold',
        shortcut: '⌘B',
        icon: CupertinoIcons.bold,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertBold();
        },
      ),
      _CommandItem(
        label: 'Italic',
        shortcut: '⌘I',
        icon: CupertinoIcons.italic,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertItalic();
        },
      ),
      _CommandItem(
        label: 'Strikethrough',
        shortcut: '⌘⇧S',
        icon: CupertinoIcons.strikethrough,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertStrikethrough();
        },
      ),
      _CommandItem(
        label: 'Heading 1',
        shortcut: '⌘1',
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertHeading1();
        },
      ),
      _CommandItem(
        label: 'Heading 2',
        shortcut: '⌘2',
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertHeading2();
        },
      ),
      _CommandItem(
        label: 'Heading 3',
        shortcut: '⌘3',
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertHeading3();
        },
      ),
      _CommandItem(
        label: 'Insert Link',
        shortcut: '⌘K',
        icon: CupertinoIcons.link,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertLink();
        },
      ),
      _CommandItem(
        label: 'Insert Image',
        shortcut: '⌘⇧I',
        icon: CupertinoIcons.photo,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertImage();
        },
      ),
      _CommandItem(
        label: 'Bullet List',
        shortcut: '⌘⇧U',
        icon: CupertinoIcons.list_bullet,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertBulletList();
        },
      ),
      _CommandItem(
        label: 'Numbered List',
        shortcut: '⌘⇧O',
        icon: CupertinoIcons.list_number,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertNumberedList();
        },
      ),
      _CommandItem(
        label: 'Checklist',
        shortcut: '⌘⇧L',
        icon: CupertinoIcons.checkmark_square,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertChecklist();
        },
      ),
      _CommandItem(
        label: 'Code Block',
        shortcut: '⌘⇧C',
        icon: CupertinoIcons.chevron_left_slash_chevron_right,
        category: 'Formatting',
        action: () {
          Navigator.pop(context);
          widget.editorKey?.currentState?.insertCodeBlock();
        },
      ),

      // Help
      _CommandItem(
        label: 'Show Keyboard Shortcuts',
        shortcut: '⌘/',
        icon: CupertinoIcons.keyboard,
        category: 'Help',
        action: () {
          Navigator.pop(context);
          widget.onShowShortcuts();
        },
      ),
    ];
  }

  void _filterCommands(String query) {
    setState(() {
      _query = query.toLowerCase();
      if (_query.isEmpty) {
        _filteredCommands = _allCommands;
      } else {
        _filteredCommands =
            _allCommands.where((cmd) {
              return cmd.label.toLowerCase().contains(_query) ||
                  cmd.category.toLowerCase().contains(_query);
            }).toList();
      }
      _selectedIndex = 0;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex =
            _selectedIndex > 0
                ? _selectedIndex - 1
                : _filteredCommands.length - 1;
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter &&
        _filteredCommands.isNotEmpty) {
      _filteredCommands[_selectedIndex].action();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: Center(
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.elevated(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              Container(
                padding: const EdgeInsets.all(12),
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
                      CupertinoIcons.search,
                      color: AppTheme.textSecondary(context),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoTextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        placeholder: 'Type a command...',
                        placeholderStyle: AppTheme.placeholder(context),
                        style: AppTheme.body(context),
                        decoration: null,
                        padding: EdgeInsets.zero,
                        onChanged: _filterCommands,
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Flexible(
                child:
                    _filteredCommands.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredCommands.length,
                          itemBuilder: (context, index) {
                            final command = _filteredCommands[index];
                            final isSelected = index == _selectedIndex;

                            return _CommandItemWidget(
                              item: command,
                              isSelected: isSelected,
                              query: _query,
                              onTap: command.action,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 32,
            color: AppTheme.textTertiary(context),
          ),
          const SizedBox(height: 12),
          Text(
            'No commands found',
            style: AppTheme.body(
              context,
            ).copyWith(color: AppTheme.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}

class _CommandItem {
  final String label;
  final String? shortcut;
  final IconData? icon;
  final String category;
  final bool isDestructive;
  final VoidCallback action;

  _CommandItem({
    required this.label,
    this.shortcut,
    this.icon,
    required this.category,
    this.isDestructive = false,
    required this.action,
  });
}

class _CommandItemWidget extends StatefulWidget {
  final _CommandItem item;
  final bool isSelected;
  final String query;
  final VoidCallback onTap;

  const _CommandItemWidget({
    required this.item,
    required this.isSelected,
    required this.query,
    required this.onTap,
  });

  @override
  State<_CommandItemWidget> createState() => _CommandItemWidgetState();
}

class _CommandItemWidgetState extends State<_CommandItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.fastAnimation,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.accent.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      widget.isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Icon
              if (widget.item.icon != null)
                Icon(
                  widget.item.icon,
                  size: 18,
                  color:
                      widget.item.isDestructive
                          ? AppColors.red
                          : AppTheme.textSecondary(context),
                ),
              if (widget.item.icon != null) const SizedBox(width: 12),

              // Label
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppTheme.body(context).copyWith(
                    color:
                        widget.item.isDestructive
                            ? AppColors.red
                            : AppTheme.textPrimary(context),
                  ),
                ),
              ),

              // Shortcut
              if (widget.item.shortcut != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.toolbarButton(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.item.shortcut!,
                    style: AppTheme.footnote(
                      context,
                    ).copyWith(fontFamily: 'SF Mono'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Need to add Colors import
class Colors {
  static const transparent = Color(0x00000000);
}
