import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../app/theme/app_theme.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/notes_list/notes_list.dart';
import '../widgets/editor/note_editor.dart';
import '../widgets/keyboard_shortcuts/shortcuts_help_dialog.dart';
import '../widgets/command_palette/command_palette_config.dart';
import '../database_helper.dart';
import '../models/folder.dart';

/// Enum for sidebar navigation sections
enum SidebarSection { allNotes, favorites, recents, folder }

/// Main home screen with three-column layout:
/// Sidebar | Notes List | Editor
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Database
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Layout state
  bool _sidebarCollapsed = false;
  double _sidebarWidth = AppTheme.sidebarDefaultWidth;
  double _notesListWidth = AppTheme.notesListDefaultWidth;

  // Sidebar state
  SidebarSection _selectedSection = SidebarSection.allNotes;
  int? _selectedFolderId;

  // Notes state
  List<Map<String, dynamic>> _notes = [];
  List<Folder> _folders = [];
  int? _selectedNoteId;
  bool _isLoading = true;
  String _searchQuery = '';

  // Editor state
  bool _isPreviewMode = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<NoteEditorState> _editorKey = GlobalKey();

  // Focus
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _notesListFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _keyboardFocusNode.dispose();
    _notesListFocusNode.dispose();
    super.dispose();
  }

  // ============================================
  // DATA LOADING
  // ============================================

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.wait([_loadNotes(), _loadFolders()]);

    setState(() => _isLoading = false);
  }

  Future<void> _loadNotes() async {
    List<Map<String, dynamic>> notes;

    if (_searchQuery.isNotEmpty) {
      notes = await _databaseHelper.searchNotes(_searchQuery);
    } else {
      switch (_selectedSection) {
        case SidebarSection.allNotes:
          notes = await _databaseHelper.getNotes();
          break;
        case SidebarSection.favorites:
          notes = await _databaseHelper.getFavoriteNotes();
          break;
        case SidebarSection.recents:
          notes = await _databaseHelper.getRecentNotes();
          break;
        case SidebarSection.folder:
          if (_selectedFolderId != null) {
            notes = await _databaseHelper.getNotesByFolder(_selectedFolderId!);
          } else {
            notes = await _databaseHelper.getNotes();
          }
          break;
      }
    }

    if (mounted) {
      setState(() {
        _notes = notes;
        // If selected note is no longer in the list, deselect it
        if (_selectedNoteId != null &&
            !notes.any((n) => n['id'] == _selectedNoteId)) {
          _selectedNoteId = null;
          _clearEditor();
        }
      });
    }
  }

  Future<void> _loadFolders() async {
    final folders = await _databaseHelper.getFolders();
    if (mounted) {
      setState(() {
        _folders = folders.map((f) => Folder.fromMap(f)).toList();
      });
    }
  }

  // ============================================
  // SIDEBAR ACTIONS
  // ============================================

  void _onSidebarSectionChanged(SidebarSection section, {int? folderId}) {
    setState(() {
      _selectedSection = section;
      _selectedFolderId = folderId;
      _searchQuery = '';
    });
    _loadNotes();
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarCollapsed = !_sidebarCollapsed;
    });
  }

  // ============================================
  // NOTES LIST ACTIONS
  // ============================================

  void _onNoteSelected(int noteId) async {
    // Save current note if there are changes
    await _saveCurrentNote();

    // Mark note as opened for recents
    await _databaseHelper.markNoteAsOpened(noteId);

    // Load the selected note
    final note = await _databaseHelper.getNote(noteId);
    if (note != null && mounted) {
      setState(() {
        _selectedNoteId = noteId;
        _titleController.text = note['title'] ?? '';
        _contentController.text = note['note'] ?? '';
        _isPreviewMode = true; // Start in preview mode for existing notes
      });
    }
  }

  Future<void> _createNewNote() async {
    // Save current note first
    await _saveCurrentNote();

    final now = DateTime.now().toIso8601String();
    final noteData = {
      'title': '',
      'note': '',
      'created_at': now,
      'updated_at': now,
      'last_opened_at': now,
      'is_favorite': 0,
      'folder_id':
          _selectedSection == SidebarSection.folder ? _selectedFolderId : null,
    };

    final id = await _databaseHelper.insertNote(noteData);

    setState(() {
      _selectedNoteId = id;
      _titleController.text = '';
      _contentController.text = '';
      _isPreviewMode = false; // Start in edit mode for new notes
    });

    await _loadNotes();

    // Focus the editor
    _editorKey.currentState?.focusContent();
  }

  Future<void> _deleteCurrentNote() async {
    if (_selectedNoteId == null) return;
    await _deleteNoteById(_selectedNoteId!);
  }

  Future<void> _deleteNoteById(int noteId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true) {
      await _databaseHelper.deleteNote(noteId);
      setState(() {
        // If we deleted the currently selected note, clear it
        if (_selectedNoteId == noteId) {
          _selectedNoteId = null;
          _clearEditor();
        }
      });
      await _loadNotes();
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showCupertinoDialog<bool>(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Delete Note'),
            content: const Text(
              'Are you sure you want to delete this note? This cannot be undone.',
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadNotes();
  }

  void _onToggleFavorite(int noteId) async {
    await _databaseHelper.toggleFavorite(noteId);
    await _loadNotes();
  }

  // ============================================
  // EDITOR ACTIONS
  // ============================================

  void _clearEditor() {
    _titleController.clear();
    _contentController.clear();
    _isPreviewMode = false;
  }

  Future<void> _saveCurrentNote() async {
    if (_selectedNoteId == null) return;
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return;
    }

    final now = DateTime.now().toIso8601String();
    await _databaseHelper.updateNote({
      'id': _selectedNoteId,
      'title':
          _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
      'note': _contentController.text,
      'updated_at': now,
    });
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  // ============================================
  // FOLDER ACTIONS
  // ============================================

  Future<void> _createFolder(String name, String color) async {
    await _databaseHelper.insertFolder({'name': name, 'color': color});
    await _loadFolders();
  }

  Future<void> _updateFolder(int id, String name, String color) async {
    await _databaseHelper.updateFolder({
      'id': id,
      'name': name,
      'color': color,
    });
    await _loadFolders();
  }

  Future<void> _deleteFolder(int id) async {
    await _databaseHelper.deleteFolder(id);

    // If we were viewing this folder, switch to All Notes
    if (_selectedSection == SidebarSection.folder && _selectedFolderId == id) {
      _onSidebarSectionChanged(SidebarSection.allNotes);
    }

    await _loadFolders();
    await _loadNotes();
  }

  // ============================================
  // KEYBOARD SHORTCUTS
  // ============================================

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final bool isMeta = HardwareKeyboard.instance.isMetaPressed;
    final bool isShift = HardwareKeyboard.instance.isShiftPressed;

    // Cmd+N: New note
    if (isMeta && event.logicalKey == LogicalKeyboardKey.keyN) {
      _createNewNote();
      return KeyEventResult.handled;
    }

    // Cmd+\: Toggle sidebar
    if (isMeta && event.logicalKey == LogicalKeyboardKey.backslash) {
      _toggleSidebar();
      return KeyEventResult.handled;
    }

    // Cmd+Shift+P: Command palette
    if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyP) {
      _showCommandPalette();
      return KeyEventResult.handled;
    }

    // Cmd+/: Show shortcuts help
    if (isMeta && event.logicalKey == LogicalKeyboardKey.slash) {
      _showShortcutsHelp();
      return KeyEventResult.handled;
    }

    // Cmd+Shift+1: All Notes
    if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.digit1) {
      _onSidebarSectionChanged(SidebarSection.allNotes);
      return KeyEventResult.handled;
    }

    // Cmd+Shift+2: Favorites
    if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.digit2) {
      _onSidebarSectionChanged(SidebarSection.favorites);
      return KeyEventResult.handled;
    }

    // Cmd+Shift+3: Recents
    if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.digit3) {
      _onSidebarSectionChanged(SidebarSection.recents);
      return KeyEventResult.handled;
    }

    // Cmd+Enter: Toggle preview
    if (isMeta && event.logicalKey == LogicalKeyboardKey.enter) {
      _togglePreviewMode();
      return KeyEventResult.handled;
    }

    // Cmd+Backspace: Delete note
    if (isMeta && event.logicalKey == LogicalKeyboardKey.backspace) {
      _deleteCurrentNote();
      return KeyEventResult.handled;
    }

    // Cmd+S: Save
    if (isMeta && event.logicalKey == LogicalKeyboardKey.keyS) {
      _saveCurrentNote();
      return KeyEventResult.handled;
    }

    // Escape: Various close actions
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Could deselect note or close dialogs
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  void _showCommandPalette() {
    CommandPaletteConfig.show(
      context: context,
      onNewNote: _createNewNote,
      onToggleSidebar: _toggleSidebar,
      onTogglePreview: _togglePreviewMode,
      onShowShortcuts: _showShortcutsHelp,
      onGoToAllNotes: () => _onSidebarSectionChanged(SidebarSection.allNotes),
      onGoToFavorites: () => _onSidebarSectionChanged(SidebarSection.favorites),
      onGoToRecents: () => _onSidebarSectionChanged(SidebarSection.recents),
      onDeleteNote: _deleteCurrentNote,
      onSave: _saveCurrentNote,
      editorKey: _editorKey,
    );
  }

  void _showShortcutsHelp() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ShortcutsHelpDialog(),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: CupertinoPageScaffold(
        backgroundColor: AppTheme.windowBg(context),
        child: SafeArea(
          child: Row(
            children: [
              // Sidebar
              if (!_sidebarCollapsed) _buildSidebar(),

              // Notes List
              _buildNotesList(),

              // Editor
              Expanded(child: _buildEditor()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: AppTheme.fastAnimation,
      width: _sidebarCollapsed ? 0 : _sidebarWidth,
      child: Sidebar(
        selectedSection: _selectedSection,
        selectedFolderId: _selectedFolderId,
        folders: _folders,
        onSectionChanged: _onSidebarSectionChanged,
        onCreateFolder: _createFolder,
        onUpdateFolder: _updateFolder,
        onDeleteFolder: _deleteFolder,
        onShowShortcuts: _showShortcutsHelp,
      ),
    );
  }

  Widget _buildNotesList() {
    return Container(
      width: _notesListWidth,
      decoration: BoxDecoration(border: AppTheme.panelBorder(context)),
      child: NotesList(
        notes: _notes,
        selectedNoteId: _selectedNoteId,
        isLoading: _isLoading,
        searchQuery: _searchQuery,
        onNoteSelected: _onNoteSelected,
        onSearchChanged: _onSearchChanged,
        onCreateNote: _createNewNote,
        onToggleFavorite: _onToggleFavorite,
        onDeleteNote: _deleteNoteById,
        focusNode: _notesListFocusNode,
      ),
    );
  }

  Widget _buildEditor() {
    if (_selectedNoteId == null) {
      return _buildEmptyState();
    }

    return NoteEditor(
      key: _editorKey,
      noteId: _selectedNoteId!,
      titleController: _titleController,
      contentController: _contentController,
      isPreviewMode: _isPreviewMode,
      onTogglePreview: _togglePreviewMode,
      onSave: _saveCurrentNote,
      onDelete: _deleteCurrentNote,
      databaseHelper: _databaseHelper,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppTheme.contentBg(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 64,
              color: AppTheme.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a note or create a new one',
              style: AppTheme.body(
                context,
              ).copyWith(color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: _createNewNote,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.add, size: 18),
                  SizedBox(width: 8),
                  Text('New Note'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('or press ⌘N', style: AppTheme.footnote(context)),
          ],
        ),
      ),
    );
  }
}
