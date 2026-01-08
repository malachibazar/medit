import 'package:flutter/cupertino.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import '../../models/folder.dart';
import '../../screens/home_screen.dart';
import 'folder_dialog.dart';

/// Navigation sidebar with sections: All Notes, Favorites, Recents, Folders
class Sidebar extends StatefulWidget {
  final SidebarSection selectedSection;
  final int? selectedFolderId;
  final List<Folder> folders;
  final Function(SidebarSection, {int? folderId}) onSectionChanged;
  final Function(String name, String color) onCreateFolder;
  final Function(int id, String name, String color) onUpdateFolder;
  final Function(int id) onDeleteFolder;
  final VoidCallback? onShowShortcuts;

  const Sidebar({
    super.key,
    required this.selectedSection,
    this.selectedFolderId,
    required this.folders,
    required this.onSectionChanged,
    required this.onCreateFolder,
    required this.onUpdateFolder,
    required this.onDeleteFolder,
    this.onShowShortcuts,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _foldersExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.sidebarBg(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // Main sections
          _buildSidebarItem(
            icon: CupertinoIcons.doc_text,
            label: 'All Notes',
            isSelected: widget.selectedSection == SidebarSection.allNotes,
            shortcut: '⌘⇧1',
            onTap: () => widget.onSectionChanged(SidebarSection.allNotes),
          ),
          _buildSidebarItem(
            icon: CupertinoIcons.star_fill,
            label: 'Favorites',
            isSelected: widget.selectedSection == SidebarSection.favorites,
            shortcut: '⌘⇧2',
            iconColor: AppColors.yellow,
            onTap: () => widget.onSectionChanged(SidebarSection.favorites),
          ),
          _buildSidebarItem(
            icon: CupertinoIcons.clock,
            label: 'Recents',
            isSelected: widget.selectedSection == SidebarSection.recents,
            shortcut: '⌘⇧3',
            onTap: () => widget.onSectionChanged(SidebarSection.recents),
          ),

          const SizedBox(height: 8),
          _buildSeparator(),
          const SizedBox(height: 8),

          // Folders section header
          _buildSectionHeader(
            'FOLDERS',
            isExpanded: _foldersExpanded,
            onTap: () => setState(() => _foldersExpanded = !_foldersExpanded),
          ),

          // Folders list
          if (_foldersExpanded) ...[
            for (final folder in widget.folders) _buildFolderItem(folder),

            const SizedBox(height: 4),
            _buildNewFolderButton(),
          ],

          const Spacer(),

          // Bottom section (future: settings)
          _buildSeparator(),
          const SizedBox(height: 8),
          _buildSidebarItem(
            icon: CupertinoIcons.keyboard,
            label: 'Shortcuts',
            isSelected: false,
            shortcut: '⌘/',
            onTap: () {
              widget.onShowShortcuts?.call();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    String? shortcut,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return _SidebarItemWidget(
      icon: icon,
      label: label,
      isSelected: isSelected,
      shortcut: shortcut,
      iconColor: iconColor,
      onTap: onTap,
    );
  }

  Widget _buildFolderItem(Folder folder) {
    final isSelected =
        widget.selectedSection == SidebarSection.folder &&
        widget.selectedFolderId == folder.id;

    return GestureDetector(
      onSecondaryTap: () => _showFolderContextMenu(folder),
      child: _SidebarItemWidget(
        icon: CupertinoIcons.folder_fill,
        label: folder.name,
        isSelected: isSelected,
        iconColor: folder.folderColor,
        onTap:
            () => widget.onSectionChanged(
              SidebarSection.folder,
              folderId: folder.id,
            ),
        onSecondaryTap: () => _showFolderContextMenu(folder),
      ),
    );
  }

  void _showFolderContextMenu(Folder folder) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditFolderDialog(folder);
                },
                child: const Text('Rename Folder'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showColorPicker(folder);
                },
                child: const Text('Change Color'),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDeleteFolder(folder);
                },
                child: const Text('Delete Folder'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  void _showEditFolderDialog(Folder folder) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => FolderDialog(
            folder: folder,
            onSave: (name, color) {
              widget.onUpdateFolder(folder.id!, name, color);
            },
          ),
    );
  }

  void _showColorPicker(Folder folder) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.elevated(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose Color', style: AppTheme.headline(context)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (int i = 0; i < AppColors.folderColors.length; i++)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onUpdateFolder(
                            folder.id!,
                            folder.name,
                            AppColors.colorToHex(AppColors.folderColors[i]),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.folderColors[i],
                            shape: BoxShape.circle,
                            border:
                                folder.color ==
                                        AppColors.colorToHex(
                                          AppColors.folderColors[i],
                                        )
                                    ? Border.all(
                                      color: AppTheme.textPrimary(context),
                                      width: 2,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDeleteFolder(Folder folder) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Delete Folder'),
            content: Text(
              'Are you sure you want to delete "${folder.name}"? Notes in this folder will be moved to All Notes.',
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDeleteFolder(folder.id!);
                },
                child: const Text('Delete'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildNewFolderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () {
          showCupertinoDialog(
            context: context,
            builder: (context) => FolderDialog(onSave: widget.onCreateFolder),
          );
        },
        child: Row(
          children: [
            Icon(
              CupertinoIcons.add,
              size: 16,
              color: AppTheme.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Text(
              'New Folder',
              style: AppTheme.subhead(
                context,
              ).copyWith(color: AppTheme.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Text(title, style: AppTheme.sectionHeader(context)),
            const Spacer(),
            Icon(
              isExpanded
                  ? CupertinoIcons.chevron_down
                  : CupertinoIcons.chevron_right,
              size: 12,
              color: AppTheme.textTertiary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppTheme.separator(context),
    );
  }
}

/// Individual sidebar item with hover and selection states
class _SidebarItemWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? shortcut;
  final Color? iconColor;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  const _SidebarItemWidget({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.shortcut,
    this.iconColor,
    required this.onTap,
    this.onSecondaryTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onSecondaryTap,
        child: AnimatedContainer(
          duration: AppTheme.fastAnimation,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: AppTheme.sidebarItemDecoration(
            context,
            isSelected: widget.isSelected,
            isHovered: _isHovered,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 16,
                color:
                    widget.iconColor ??
                    (widget.isSelected
                        ? AppColors.accent
                        : AppTheme.textSecondary(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTheme.subhead(context).copyWith(
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        widget.isSelected
                            ? AppColors.accent
                            : AppTheme.textPrimary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.shortcut != null && _isHovered)
                Text(widget.shortcut!, style: AppTheme.caption(context)),
            ],
          ),
        ),
      ),
    );
  }
}
