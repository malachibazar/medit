import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'database_helper.dart';
import 'main.dart';

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

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  // Add didChangeDependencies to refresh notes when returning to this screen
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
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            // Navigate to create a new note - new notes start in edit mode
            Navigator.of(context)
                .push(
                  CupertinoPageRoute(
                    builder: (context) => const NotepadHomePage(
                      startInViewMode: false, // New notes should start in edit mode
                    ),
                  ),
                )
                .then((_) => _refreshNotes());
          },
        ),
      ),
      child: SafeArea(
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
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                                CupertinoPageRoute(
                                  builder: (context) => const NotepadHomePage(
                                    startInViewMode: false, // New notes should start in edit mode
                                  ),
                                ),
                              )
                              .then((_) => _refreshNotes());
                        },
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
                                      startInViewMode: true, // Existing notes open in view mode
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
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
