import 'package:flutter/cupertino.dart';
import 'note_tab.dart';
import 'notes_list_screen.dart';

void main() {
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Medit',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: NotesListScreen(),
    );
  }
}

class NotepadHomePage extends StatefulWidget {
  final int? noteId;
  final String? initialTitle;
  final String? initialContent;
  final bool startInViewMode;

  const NotepadHomePage({
    super.key,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.startInViewMode =
        true, // Default to view mode when opening existing notes
  });

  @override
  NotepadHomePageState createState() => NotepadHomePageState();
}

class NotepadHomePageState extends State<NotepadHomePage> {
  late TextEditingController _textController;
  late TextEditingController _titleController;
  final GlobalKey<State<NoteTab>> _noteTabKey = GlobalKey();
  late NoteTab _noteTab;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialContent ?? '');
    _titleController = TextEditingController(text: widget.initialTitle ?? '');

    // Create the NoteTab instance that will be used throughout
    _noteTab = NoteTab(
      key: _noteTabKey,
      textController: _textController,
      titleController: _titleController,
      noteId: widget.noteId,
      startInViewMode:
          widget.startInViewMode &&
          widget.noteId != null, // Only start in view mode for existing notes
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercept back button/gesture to ensure save completes
      onWillPop: () async {
        // Force immediate save before popping
        if (_textController.text.isNotEmpty ||
            _titleController.text.isNotEmpty) {
          final state = _noteTabKey.currentState;
          if (state != null) {
            // Call forceSave through the state object
            (state as dynamic).forceSave();
            // Small delay to allow save to complete
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
        return true;
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // Add trailing delete button only for existing notes
          trailing:
              widget.noteId != null
                  ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: CupertinoColors.systemRed,
                    ),
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
                                    final state = _noteTabKey.currentState;
                                    if (state != null) {
                                      (state as dynamic).deleteNote();
                                    }
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
                  )
                  : null,
        ),
        child: SafeArea(child: _noteTab),
      ),
    );
  }
}
