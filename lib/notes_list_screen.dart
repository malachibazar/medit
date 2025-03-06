import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Add services import for keyboard shortcuts
import 'dart:io';
import 'database_helper.dart';
import 'main.dart';
import 'package:file_picker/file_picker.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  bool _didInitialLoad = false;
  final FocusNode _keyboardFocusNode =
      FocusNode(); // Add focus node for keyboard shortcuts

  @override
  void initState() {
    super.initState();
    _refreshNotes();
    _keyboardFocusNode.onKeyEvent = _handleKeyEvent; // Set up key event handler
    // Request focus when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cancel any pending focus requests
      _keyboardFocusNode.unfocus();
    });
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Handle Command+N to create new note
    if (event.logicalKey == LogicalKeyboardKey.keyN &&
        HardwareKeyboard.instance.isMetaPressed) {
      _createNewNote();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // Extract new note creation logic to a method so it can be reused
  void _createNewNote() {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder:
                (context) => const NotepadHomePage(
                  startInViewMode: false, // Ensure new notes start in edit mode
                  noteId: null, // Explicitly set noteId to null for new notes
                ),
          ),
        )
        .then((_) => _refreshNotes());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we've already done the initial load
    if (_didInitialLoad) {
      _refreshNotes();
    }
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _isLoading = true;
    });

    final notes = await _databaseHelper.getNotes();

    if (mounted) {
      setState(() {
        _notes = notes;
        _isLoading = false;
        _didInitialLoad = true;
      });
    }
  }

  Future<void> _deleteNote(int id) async {
    await _databaseHelper.deleteNote(id);
    _refreshNotes();
  }

  // File opening functionality
  Future<void> _openFile() async {
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

        // Navigate to a new note with the imported content
        if (context.mounted) {
          Navigator.of(context)
              .push(
                CupertinoPageRoute(
                  builder:
                      (context) => NotepadHomePage(
                        initialTitle: title,
                        initialContent: contents,
                        startInViewMode:
                            false, // Start in edit mode for imported files
                      ),
                ),
              )
              .then((_) => _refreshNotes());
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

  // Simple text preview from markdown content
  String _getPlainTextPreview(String markdownText) {
    // Strip markdown syntax for preview
    final preview =
        markdownText
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
              '[Code Block]',
            ) // Remove code blocks
            .trim();

    return preview.length > 150 ? '${preview.substring(0, 150)}...' : preview;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('All Notes'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Open file button
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.doc_text_fill),
              onPressed: _openFile,
            ),
            const SizedBox(width: 8),
            // New note button
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add),
              onPressed: _createNewNote,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            final result = _handleKeyEvent(node, event);
            if (result == KeyEventResult.handled) {
              return KeyEventResult.handled;
            }
            return KeyEventResult.skipRemainingHandlers;
          },
          child:
              _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _notes.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No notes yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Open file button for empty state
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(CupertinoIcons.doc_text_fill),
                                  const SizedBox(width: 8),
                                  const Text('Open File'),
                                ],
                              ),
                              onPressed: _openFile,
                            ),
                            const SizedBox(width: 16),
                            // New note button for empty state
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(CupertinoIcons.add_circled),
                                  const SizedBox(width: 8),
                                  const Text('New Note'),
                                ],
                              ),
                              onPressed: _createNewNote,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      final DateTime updatedAt =
                          DateTime.tryParse(note['updated_at'] ?? '') ??
                          DateTime.now();
                      final String formattedDate =
                          '${updatedAt.month}/${updatedAt.day}/${updatedAt.year} ${_formatTime(updatedAt)}';

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                CupertinoPageRoute(
                                  builder:
                                      (context) => NotepadHomePage(
                                        noteId: note['id'],
                                        initialTitle: note['title'],
                                        initialContent: note['note'],
                                        startInViewMode:
                                            true, // Existing notes open in view mode
                                      ),
                                ),
                              )
                              .then((_) => _refreshNotes());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: CupertinoColors.systemGrey5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    // Use plain text preview instead of markdown to avoid overflow issues
                                    Text(
                                      _getPlainTextPreview(note['note'] ?? ''),
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: CupertinoColors.systemGrey,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Updated: $formattedDate',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoButton(
                                padding: const EdgeInsets.only(left: 8.0),
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder:
                                        (context) => CupertinoAlertDialog(
                                          title: const Text('Delete Note'),
                                          content: const Text(
                                            'Are you sure you want to delete this note?',
                                          ),
                                          actions: [
                                            CupertinoDialogAction(
                                              isDestructiveAction: true,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteNote(note['id']);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                            CupertinoDialogAction(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: CupertinoColors.systemRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
