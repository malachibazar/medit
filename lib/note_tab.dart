import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for keyboard shortcuts
import 'dart:async';
import 'dart:io';
import 'database_helper.dart';
import 'markdown_view.dart';
import 'main.dart'; // Add import for AppColors
import 'package:file_picker/file_picker.dart';

class NoteTab extends StatefulWidget {
  final TextEditingController textController;
  final TextEditingController titleController;
  final int? noteId;
  final bool startInViewMode;

  const NoteTab({
    super.key,
    required this.textController,
    required this.titleController,
    this.noteId,
    this.startInViewMode = false,
  });

  @override
  State<NoteTab> createState() => _NoteTabState();
}

class _NoteTabState extends State<NoteTab> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _noteBodyFocusNode = FocusNode();
  Timer? _saveTimer;
  bool _isNewNote = true;
  bool _hasChanges = false;
  bool _isPreviewMode = false;
  int? _currentNoteId;

  @override
  void initState() {
    super.initState();
    _currentNoteId = widget.noteId;
    _isNewNote = _currentNoteId == null;
    _isPreviewMode = widget.startInViewMode;

    // Set up listeners for text changes to trigger auto-save
    widget.titleController.addListener(_onTextChanged);
    widget.textController.addListener(_onTextChanged);

    // Disable system sounds for this focus node
    _keyboardFocusNode.onKeyEvent = _handleKeyEvent;

    // If this is a new note, focus the note body after the widget is built
    if (_isNewNote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _noteBodyFocusNode.requestFocus();
      });
    }
  }

  // This method handles key events and returns whether the event was handled
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // We only want to handle key down events
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    bool handled = false;

    // Handle Return key in preview mode - switch to edit mode
    if (_isPreviewMode &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      _togglePreviewMode();
      handled = true;
    }
    // Handle Command+Return in edit mode - switch to preview mode
    else if (!_isPreviewMode &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        HardwareKeyboard.instance.isMetaPressed) {
      // Meta key is Command on Mac
      _togglePreviewMode();
      handled = true;
    }
    // Handle Escape key - return to notes list
    else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_hasChanges) {
        _saveNote().then((_) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        Navigator.of(context).pop();
      }
      handled = true;
    }
    // Handle the backspace key to prevent the sound when there's nothing to delete
    else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      // Check if we are in edit mode and if the text field is empty
      if (!_isPreviewMode &&
          (widget.textController.selection.isCollapsed &&
                  widget.textController.selection.baseOffset == 0 ||
              widget.textController.text.isEmpty)) {
        // Don't make the alert sound, but still let the event pass through
        // This prevents the sound but allows the cursor to be positioned properly
        return KeyEventResult.ignored;
      }
    }

    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  void _onTextChanged() {
    // Only mark as changed if there's actual content
    if (widget.textController.text.isNotEmpty ||
        widget.titleController.text.isNotEmpty) {
      _hasChanges = true;
      // Cancel previous timer if it exists
      _saveTimer?.cancel();
      // Set a new timer to save after 1 second of inactivity
      _saveTimer = Timer(const Duration(seconds: 1), _saveNote);
    }
  }

  // File opening functionality
  Future<void> openFile() async {
    // Save current note first if needed
    if (_hasChanges) {
      await _saveNote();
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'markdown', 'text'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();

        // Extract file name for the title (without extension)
        String fileName = result.files.single.name;
        String title =
            fileName.contains('.')
                ? fileName.substring(0, fileName.lastIndexOf('.'))
                : fileName;

        // Update the controllers with new content
        setState(() {
          widget.titleController.text = title;
          widget.textController.text = contents;

          // Reset note state to create a new note
          _isNewNote = true;
          _currentNoteId = null;

          // Automatically save the imported file as a new note
          _hasChanges = true;
          _saveTimer?.cancel();
          _saveTimer = Timer(const Duration(milliseconds: 500), _saveNote);
        });

        // Switch to edit mode
        if (_isPreviewMode) {
          _togglePreviewMode();
        }
      }
    } catch (e) {
      // Show error dialog
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder:
              (ctx) => CupertinoAlertDialog(
                title: const Text('Error Opening File'),
                content: Text('Could not open the file: ${e.toString()}'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
        );
      }
    }
  }

  void _togglePreviewMode() {
    if (_isPreviewMode) {
      // When switching to edit mode from preview, request focus immediately
      _noteBodyFocusNode.requestFocus();
    } else {
      // When switching to preview mode, unfocus the text field but keep keyboard focus
      _noteBodyFocusNode.unfocus();
      _keyboardFocusNode.requestFocus();
    }
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  // Public method to force an immediate save
  Future<void> forceSave() async {
    // Cancel any pending auto-save timer
    _saveTimer?.cancel();

    // Only proceed if there's content to save
    if (widget.textController.text.isNotEmpty ||
        widget.titleController.text.isNotEmpty) {
      await _saveNote();
    }
  }

  Future<void> _saveNote() async {
    if (!_hasChanges && !_isNewNote) return;

    // Don't save if both title and note are empty
    if (widget.titleController.text.isEmpty &&
        widget.textController.text.isEmpty) {
      _hasChanges = false;
      return;
    }

    final now = DateTime.now().toIso8601String();
    final Map<String, dynamic> noteData = {
      'title':
          widget.titleController.text.isEmpty
              ? 'Untitled'
              : widget.titleController.text,
      'note': widget.textController.text,
      'updated_at': now,
    };

    if (_isNewNote) {
      // For new notes, add created_at timestamp and insert
      noteData['created_at'] = now;
      final id = await _databaseHelper.insertNote(noteData);
      // Update the state to no longer be a new note and store the ID
      setState(() {
        _isNewNote = false;
        _currentNoteId = id;
      });
    } else {
      // For existing notes, update the entry
      noteData['id'] = _currentNoteId;
      await _databaseHelper.updateNote(noteData);
    }

    _hasChanges = false;
  }

  // Public method to delete the note
  Future<void> deleteNote() async {
    if (_currentNoteId != null) {
      await _databaseHelper.deleteNote(_currentNoteId!);
      if (context.mounted) {
        // Ensure we're popping the correct route by using the root navigator
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  void dispose() {
    // Save any unsaved changes before disposing
    if (_hasChanges) {
      // We use a synchronous version to ensure it completes before dispose
      _saveNoteSync();
    }

    // Cancel the timer
    _saveTimer?.cancel();

    // Remove listeners
    widget.titleController.removeListener(_onTextChanged);
    widget.textController.removeListener(_onTextChanged);

    _scrollController.dispose();
    _previewScrollController.dispose();
    _keyboardFocusNode.dispose();
    _noteBodyFocusNode.dispose();

    super.dispose();
  }

  // Synchronous wrapper for _saveNote to ensure it completes before widget disposal
  void _saveNoteSync() {
    _saveNote();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is enabled
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    // Define text colors based on theme
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final placeholderColor =
        isDarkMode
            ? CupertinoColors.systemGrey.withOpacity(0.8)
            : CupertinoColors.systemGrey;

    // Define field appearance with lighter grays for dark mode
    final fieldBackgroundColor =
        isDarkMode
            ? const Color(
              0xFF505050,
            ) // Lighter gray for text fields in dark mode
            : CupertinoColors.white;

    // Use centralized colors for consistency
    final containerColor =
        isDarkMode
            ? const Color(0xFF454545) // Use a shade consistent with AppColors
            : CupertinoColors.systemBackground;

    final borderColor =
        isDarkMode
            ? const Color(0xFF666666) // Lighter border for dark mode
            : CupertinoColors.systemGrey5;

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      child: Container(
        // Use app-wide background color from AppColors
        color: isDarkMode ? AppColors.darkBackground : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Title field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: isDarkMode ? 1.0 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          _isPreviewMode
                              ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  widget.titleController.text.isEmpty
                                      ? 'Untitled'
                                      : widget.titleController.text,
                                  style: TextStyle(
                                    fontFamily: '.AppleSystemUIFont',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              )
                              : Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                                decoration: BoxDecoration(
                                  color: fieldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? const Color(0xFF444444)
                                            : Colors.transparent,
                                    width: isDarkMode ? 1.0 : 0,
                                  ),
                                ),
                                child: CupertinoTextField(
                                  controller: widget.titleController,
                                  placeholder: 'Title',
                                  placeholderStyle: TextStyle(
                                    color: placeholderColor,
                                    fontSize: 18.0,
                                    fontFamily: '.AppleSystemUIFont',
                                  ),
                                  decoration: null, // Remove default decoration
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 8.0,
                                  ),
                                  style: TextStyle(
                                    fontFamily: '.AppleSystemUIFont',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                    ),
                    // File open button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: openFile,
                      child: Icon(
                        CupertinoIcons.doc_text_fill,
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
                    ),
                    // Toggle button between edit and preview modes
                    Tooltip(
                      message:
                          _isPreviewMode
                              ? 'Edit Note (Return)'
                              : 'Preview Note (⌘ Return)',
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _togglePreviewMode,
                        child: Icon(
                          _isPreviewMode
                              ? CupertinoIcons.pencil
                              : CupertinoIcons.eye,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Note content area - either editor or preview based on mode
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? const Color(
                              0xFF323234,
                            ) // Lighter gray for outer container in dark mode
                            : CupertinoColors.systemGrey6,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8.0),
                    ),
                  ),
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 1.0),
                  child:
                      _isPreviewMode
                          ? Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8.0),
                              ),
                              border: Border.all(
                                color: borderColor,
                                width: isDarkMode ? 1.0 : 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: MarkdownView(
                              data: widget.textController.text,
                              scrollController: _previewScrollController,
                            ),
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8.0),
                              ),
                              border: Border.all(
                                color: borderColor,
                                width: isDarkMode ? 1.0 : 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: fieldBackgroundColor,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? const Color(0xFF4E4E52)
                                          : Colors.transparent,
                                  width: isDarkMode ? 1.0 : 0,
                                ),
                              ),
                              child: CupertinoTextField(
                                controller: widget.textController,
                                focusNode: _noteBodyFocusNode,
                                autofocus: _isNewNote,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                placeholder:
                                    'Type your notes here using markdown...',
                                placeholderStyle: TextStyle(
                                  color: placeholderColor,
                                  fontFamily: '.AppleSystemUIFont',
                                  fontSize: 16.0,
                                ),
                                padding: const EdgeInsets.all(12.0),
                                scrollController: _scrollController,
                                onTapOutside: (_) {
                                  _noteBodyFocusNode.unfocus();
                                },
                                decoration: null, // Remove default decoration
                                style: TextStyle(
                                  fontFamily: '.AppleSystemUIFont',
                                  fontSize: 16.0,
                                  height: 1.5,
                                  color: textColor,
                                ),
                                cursorColor:
                                    CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
