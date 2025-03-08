import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'note_tab.dart';
import 'notes_list_screen.dart';

// Define app-wide colors that will be used consistently throughout the app
class AppColors {
  // Background color in dark mode - a medium gray, not black
  static const darkBackground = Color(0xFF393939);
  // Navigation bar background in dark mode
  static const darkBarBackground = Color(0xFF454545);
}

void main() {
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Medit',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        // Use our consistent dark background color
        scaffoldBackgroundColor: AppColors.darkBackground,
        barBackgroundColor: AppColors.darkBarBackground,
        // Override text theme to ensure navigation bar title is white in dark mode
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            fontFamily: '.AppleSystemUIFont',
          ),
          primaryColor: CupertinoColors.systemBlue,
        ),
      ),
      home: const NotesListScreen(),
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
    // Get the proper background color from the current theme
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode
            ? AppColors
                .darkBackground // Use consistent gray for dark mode
            : CupertinoTheme.of(context).scaffoldBackgroundColor;

    final titleColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

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
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: isDarkMode ? AppColors.darkBarBackground : null,
          // Use DefaultTextStyle to explicitly set the text color for the title
          middle:
              widget.noteId != null
                  ? DefaultTextStyle(
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: '.AppleSystemUIFont',
                    ),
                    child: Text(
                      _titleController.text.isEmpty
                          ? 'Untitled'
                          : _titleController.text,
                    ),
                  )
                  : null,
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
