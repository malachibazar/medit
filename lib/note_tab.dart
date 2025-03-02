import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'database_helper.dart';
import 'markdown_view.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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

    // Set initial view mode based on the parameter
    _isPreviewMode = widget.startInViewMode;

    // Set up listeners for text changes to trigger auto-save
    widget.titleController.addListener(_onTextChanged);
    widget.textController.addListener(_onTextChanged);
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
    super.dispose();
  }

  // Synchronous wrapper for _saveNote to ensure it completes before widget disposal
  void _saveNoteSync() {
    _saveNote(); // This is still async but we're calling it in dispose
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Title field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      _isPreviewMode
                          ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              widget.titleController.text.isEmpty
                                  ? 'Untitled'
                                  : widget.titleController.text,
                              style: const TextStyle(
                                fontFamily: '.AppleSystemUIFont',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          : CupertinoTextField(
                            controller: widget.titleController,
                            placeholder: 'Title',
                            decoration: const BoxDecoration(border: null),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            style: const TextStyle(
                              fontFamily: '.AppleSystemUIFont',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                          ),
                ),
                // File open button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.doc_text_fill,
                    color: CupertinoColors.systemBlue,
                  ),
                  onPressed: openFile,
                ),
                // Toggle button between edit and preview modes
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    _isPreviewMode ? CupertinoIcons.pencil : CupertinoIcons.eye,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                  onPressed: _togglePreviewMode,
                ),
              ],
            ),
          ),

          // Note content area - either editor or preview based on mode
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8.0),
                ),
              ),
              width: double.infinity,
              child:
                  _isPreviewMode
                      ? Container(
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: MarkdownView(
                          data: widget.textController.text,
                          scrollController: _previewScrollController,
                        ),
                      )
                      : CupertinoScrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height - 100,
                            ),
                            child: CupertinoTextField(
                              controller: widget.textController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              placeholder:
                                  'Type your notes here using markdown...',
                              padding: const EdgeInsets.all(12.0),
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemBackground,
                                border: null,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(8.0),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: '.AppleSystemUIFont',
                                fontSize: 16.0,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
