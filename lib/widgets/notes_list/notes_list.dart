import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import 'note_card.dart';

/// Notes list panel with search header and note cards
class NotesList extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final int? selectedNoteId;
  final bool isLoading;
  final String searchQuery;
  final Function(int noteId) onNoteSelected;
  final Function(String query) onSearchChanged;
  final VoidCallback onCreateNote;
  final Function(int noteId) onToggleFavorite;
  final Function(int noteId) onDeleteNote;
  final FocusNode? focusNode;

  const NotesList({
    super.key,
    required this.notes,
    this.selectedNoteId,
    required this.isLoading,
    required this.searchQuery,
    required this.onNoteSelected,
    required this.onSearchChanged,
    required this.onCreateNote,
    required this.onToggleFavorite,
    required this.onDeleteNote,
    this.focusNode,
  });

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  int _hoveredIndex = -1;
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(NotesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Arrow down: Move selection down
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_focusedIndex < widget.notes.length - 1) {
        setState(() => _focusedIndex++);
      }
      return KeyEventResult.handled;
    }

    // Arrow up: Move selection up
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_focusedIndex > 0) {
        setState(() => _focusedIndex--);
      }
      return KeyEventResult.handled;
    }

    // Enter: Select focused note
    if (event.logicalKey == LogicalKeyboardKey.enter && _focusedIndex >= 0) {
      widget.onNoteSelected(widget.notes[_focusedIndex]['id']);
      return KeyEventResult.handled;
    }

    // Cmd+F: Focus search
    if (HardwareKeyboard.instance.isMetaPressed &&
        event.logicalKey == LogicalKeyboardKey.keyF) {
      _searchFocusNode.requestFocus();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        color: AppTheme.contentBg(context),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  widget.isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : widget.notes.isEmpty
                      ? _buildEmptyState()
                      : _buildNotesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.contentBg(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.separator(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: CupertinoSearchTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              placeholder: 'Search notes...',
              onChanged: widget.onSearchChanged,
              style: AppTheme.body(context),
            ),
          ),
          const SizedBox(width: 8),
          // New note button
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minSize: 0,
            onPressed: widget.onCreateNote,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                CupertinoIcons.add,
                size: 16,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.searchQuery.isNotEmpty
                ? CupertinoIcons.search
                : CupertinoIcons.doc_text,
            size: 48,
            color: AppTheme.textTertiary(context),
          ),
          const SizedBox(height: 12),
          Text(
            widget.searchQuery.isNotEmpty ? 'No notes found' : 'No notes yet',
            style: AppTheme.body(
              context,
            ).copyWith(color: AppTheme.textSecondary(context)),
          ),
          if (widget.searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: widget.onCreateNote,
              child: const Text('Create Note'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        final note = widget.notes[index];
        final isSelected = note['id'] == widget.selectedNoteId;
        final isHovered = index == _hoveredIndex;
        final isFocused = index == _focusedIndex;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = -1),
          child: GestureDetector(
            onTap: () {
              widget.onNoteSelected(note['id']);
              setState(() => _focusedIndex = index);
            },
            child: NoteCard(
              title: note['title'] ?? 'Untitled',
              content: note['note'] ?? '',
              updatedAt:
                  DateTime.tryParse(note['updated_at'] ?? '') ?? DateTime.now(),
              isFavorite: note['is_favorite'] == 1,
              isSelected: isSelected,
              isHovered: isHovered,
              isFocused: isFocused,
              onToggleFavorite: () => widget.onToggleFavorite(note['id']),
              onDelete: () => widget.onDeleteNote(note['id']),
            ),
          ),
        );
      },
    );
  }
}
