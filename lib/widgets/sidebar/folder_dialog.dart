import 'package:flutter/cupertino.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import '../../models/folder.dart';

/// Dialog for creating or editing a folder
class FolderDialog extends StatefulWidget {
  final Folder? folder;
  final Function(String name, String color) onSave;

  const FolderDialog({super.key, this.folder, required this.onSave});

  @override
  State<FolderDialog> createState() => _FolderDialogState();
}

class _FolderDialogState extends State<FolderDialog> {
  late TextEditingController _nameController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder?.name ?? '');
    _selectedColor =
        widget.folder?.color ??
        AppColors.colorToHex(AppColors.folderColors[5]); // Default blue
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.folder != null;

    return CupertinoAlertDialog(
      title: Text(isEditing ? 'Edit Folder' : 'New Folder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Folder name',
            autofocus: true,
            padding: const EdgeInsets.all(12),
          ),
          const SizedBox(height: 16),
          Text('Color', style: AppTheme.footnote(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < AppColors.folderColors.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = AppColors.colorToHex(
                        AppColors.folderColors[i],
                      );
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.folderColors[i],
                      shape: BoxShape.circle,
                      border:
                          _selectedColor ==
                                  AppColors.colorToHex(
                                    AppColors.folderColors[i],
                                  )
                              ? Border.all(
                                color: CupertinoColors.white,
                                width: 2,
                              )
                              : null,
                      boxShadow:
                          _selectedColor ==
                                  AppColors.colorToHex(
                                    AppColors.folderColors[i],
                                  )
                              ? [
                                BoxShadow(
                                  color: AppColors.folderColors[i].withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              widget.onSave(name, _selectedColor);
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
