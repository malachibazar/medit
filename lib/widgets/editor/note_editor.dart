import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import '../../database_helper.dart';
import 'formatting_toolbar.dart';
import 'editor_status_bar.dart';
import 'markdown_view.dart';

/// Main note editor widget with formatting toolbar and preview mode
class NoteEditor extends StatefulWidget {
  final int noteId;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isPreviewMode;
  final VoidCallback onTogglePreview;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final DatabaseHelper databaseHelper;

  const NoteEditor({
    super.key,
    required this.noteId,
    required this.titleController,
    required this.contentController,
    required this.isPreviewMode,
    required this.onTogglePreview,
    required this.onSave,
    required this.onDelete,
    required this.databaseHelper,
  });

  @override
  State<NoteEditor> createState() => NoteEditorState();
}

class NoteEditorState extends State<NoteEditor> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _editorFocusNode = FocusNode();

  Timer? _saveTimer;
  bool _hasUnsavedChanges = false;
  SaveStatus _saveStatus = SaveStatus.saved;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_onContentChanged);
    widget.contentController.addListener(_onContentChanged);
  }

  @override
  void didUpdateWidget(NoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When switching from preview to edit mode, focus the content field
    if (oldWidget.isPreviewMode && !widget.isPreviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _contentFocusNode.requestFocus();
      });
    }
    // When switching to preview mode, ensure the editor focus node has focus
    // so keyboard shortcuts (like Enter to switch back) work
    if (!oldWidget.isPreviewMode && widget.isPreviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _editorFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_onContentChanged);
    widget.contentController.removeListener(_onContentChanged);
    _saveTimer?.cancel();
    _scrollController.dispose();
    _previewScrollController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
        _saveStatus = SaveStatus.unsaved;
      });
    }

    // Cancel previous timer
    _saveTimer?.cancel();

    // Set new timer for auto-save after 1 second
    _saveTimer = Timer(const Duration(seconds: 1), _autoSave);
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges) return;

    setState(() {
      _saveStatus = SaveStatus.saving;
    });

    widget.onSave();

    if (mounted) {
      setState(() {
        _hasUnsavedChanges = false;
        _saveStatus = SaveStatus.saved;
        _lastSaved = DateTime.now();
      });
    }
  }

  // Public methods for parent access
  void focusTitle() {
    _titleFocusNode.requestFocus();
  }

  void focusContent() {
    _contentFocusNode.requestFocus();
  }

  // Formatting methods
  void insertBold() => _wrapSelection('**', '**');
  void insertItalic() => _wrapSelection('*', '*');
  void insertStrikethrough() => _wrapSelection('~~', '~~');
  void insertInlineCode() => _wrapSelection('`', '`');
  void insertHeading1() => _insertAtLineStart('# ');
  void insertHeading2() => _insertAtLineStart('## ');
  void insertHeading3() => _insertAtLineStart('### ');
  void insertBulletList() => _insertAtLineStart('- ');
  void insertNumberedList() => _insertAtLineStart('1. ');
  void insertChecklist() => _insertAtLineStart('- [ ] ');
  void insertBlockquote() => _insertAtLineStart('> ');
  void insertCodeBlock() => _insertBlock('```\n', '\n```');
  void insertLink() => _insertTemplate('[', '](url)');
  void insertImage() => _insertTemplate('![', '](url)');

  void _wrapSelection(String before, String after) {
    final controller = widget.contentController;
    final text = controller.text;
    final selection = controller.selection;

    if (selection.isCollapsed) {
      // No selection, insert placeholder
      final newText = '$before$after';
      controller.text =
          text.substring(0, selection.start) +
          newText +
          text.substring(selection.end);
      controller.selection = TextSelection.collapsed(
        offset: selection.start + before.length,
      );
    } else {
      // Wrap selected text
      final selectedText = text.substring(selection.start, selection.end);
      final newText = '$before$selectedText$after';
      controller.text =
          text.substring(0, selection.start) +
          newText +
          text.substring(selection.end);
      controller.selection = TextSelection(
        baseOffset: selection.start + before.length,
        extentOffset: selection.start + before.length + selectedText.length,
      );
    }
    _contentFocusNode.requestFocus();
  }

  void _insertAtLineStart(String prefix) {
    final controller = widget.contentController;
    final text = controller.text;
    final selection = controller.selection;

    // Find the start of the current line
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    controller.text =
        text.substring(0, lineStart) + prefix + text.substring(lineStart);
    controller.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length,
    );
    _contentFocusNode.requestFocus();
  }

  void _insertBlock(String before, String after) {
    final controller = widget.contentController;
    final text = controller.text;
    final selection = controller.selection;

    // Ensure we're on a new line
    String prefix = '';
    if (selection.start > 0 && text[selection.start - 1] != '\n') {
      prefix = '\n';
    }

    final newText = '$prefix$before$after';
    controller.text =
        text.substring(0, selection.start) +
        newText +
        text.substring(selection.end);
    controller.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length + before.length,
    );
    _contentFocusNode.requestFocus();
  }

  void _insertTemplate(String before, String after) {
    final controller = widget.contentController;
    final text = controller.text;
    final selection = controller.selection;

    if (selection.isCollapsed) {
      // No selection, insert with placeholder
      final newText = '${before}text$after';
      controller.text =
          text.substring(0, selection.start) +
          newText +
          text.substring(selection.end);
      controller.selection = TextSelection(
        baseOffset: selection.start + before.length,
        extentOffset: selection.start + before.length + 4, // Select "text"
      );
    } else {
      // Use selected text
      final selectedText = text.substring(selection.start, selection.end);
      final newText = '$before$selectedText$after';
      controller.text =
          text.substring(0, selection.start) +
          newText +
          text.substring(selection.end);
      controller.selection = TextSelection.collapsed(
        offset: selection.start + newText.length,
      );
    }
    _contentFocusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final bool isMeta = HardwareKeyboard.instance.isMetaPressed;
    final bool isShift = HardwareKeyboard.instance.isShiftPressed;

    // Only handle formatting shortcuts in edit mode
    if (!widget.isPreviewMode) {
      // Cmd+B: Bold
      if (isMeta && event.logicalKey == LogicalKeyboardKey.keyB) {
        insertBold();
        return KeyEventResult.handled;
      }

      // Cmd+I: Italic
      if (isMeta && event.logicalKey == LogicalKeyboardKey.keyI) {
        insertItalic();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+S: Strikethrough
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyS) {
        insertStrikethrough();
        return KeyEventResult.handled;
      }

      // Cmd+1: Heading 1
      if (isMeta && !isShift && event.logicalKey == LogicalKeyboardKey.digit1) {
        insertHeading1();
        return KeyEventResult.handled;
      }

      // Cmd+2: Heading 2
      if (isMeta && !isShift && event.logicalKey == LogicalKeyboardKey.digit2) {
        insertHeading2();
        return KeyEventResult.handled;
      }

      // Cmd+3: Heading 3
      if (isMeta && !isShift && event.logicalKey == LogicalKeyboardKey.digit3) {
        insertHeading3();
        return KeyEventResult.handled;
      }

      // Cmd+K: Insert link
      if (isMeta && !isShift && event.logicalKey == LogicalKeyboardKey.keyK) {
        insertLink();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+I: Insert image
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyI) {
        insertImage();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+U: Bullet list
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyU) {
        insertBulletList();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+O: Numbered list
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyO) {
        insertNumberedList();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+L: Checklist
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyL) {
        insertChecklist();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+C: Code block
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.keyC) {
        insertCodeBlock();
        return KeyEventResult.handled;
      }

      // Cmd+`: Inline code
      if (isMeta && event.logicalKey == LogicalKeyboardKey.backquote) {
        insertInlineCode();
        return KeyEventResult.handled;
      }

      // Cmd+Shift+.: Blockquote
      if (isMeta && isShift && event.logicalKey == LogicalKeyboardKey.period) {
        insertBlockquote();
        return KeyEventResult.handled;
      }
    }

    // Enter in preview mode: switch to edit
    if (widget.isPreviewMode &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !isMeta) {
      widget.onTogglePreview();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _editorFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        color: AppTheme.contentBg(context),
        child: Column(
          children: [
            // Formatting toolbar (only in edit mode)
            if (!widget.isPreviewMode)
              FormattingToolbar(
                onBold: insertBold,
                onItalic: insertItalic,
                onStrikethrough: insertStrikethrough,
                onHeading1: insertHeading1,
                onHeading2: insertHeading2,
                onHeading3: insertHeading3,
                onBulletList: insertBulletList,
                onNumberedList: insertNumberedList,
                onChecklist: insertChecklist,
                onBlockquote: insertBlockquote,
                onInlineCode: insertInlineCode,
                onCodeBlock: insertCodeBlock,
                onLink: insertLink,
                onImage: insertImage,
                onTogglePreview: widget.onTogglePreview,
                isPreviewMode: widget.isPreviewMode,
              ),

            // Preview toggle button (in preview mode)
            if (widget.isPreviewMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.toolbarBg(context),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.separator(context),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minSize: 0,
                      onPressed: widget.onTogglePreview,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '↵',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Editor content
            Expanded(
              child:
                  widget.isPreviewMode ? _buildPreviewMode() : _buildEditMode(),
            ),

            // Status bar
            EditorStatusBar(
              wordCount: _getWordCount(),
              charCount: widget.contentController.text.length,
              saveStatus: _saveStatus,
              lastSaved: _lastSaved,
              isPreviewMode: widget.isPreviewMode,
              onTogglePreview: widget.onTogglePreview,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title field
          CupertinoTextField(
            controller: widget.titleController,
            focusNode: _titleFocusNode,
            placeholder: 'Title',
            placeholderStyle: AppTheme.placeholder(
              context,
            ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            style: AppTheme.editorTitle(context),
            decoration: null,
            padding: const EdgeInsets.only(bottom: 16),
            maxLines: 1,
          ),

          // Divider
          Container(height: 1, color: AppTheme.separator(context)),
          const SizedBox(height: 16),

          // Content field
          Expanded(
            child: CupertinoTextField(
              controller: widget.contentController,
              focusNode: _contentFocusNode,
              scrollController: _scrollController,
              placeholder: 'Start writing...',
              placeholderStyle: AppTheme.placeholder(context),
              style: AppTheme.editorBody(context),
              decoration: null,
              padding: EdgeInsets.zero,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewMode() {
    return GestureDetector(
      onDoubleTap: widget.onTogglePreview,
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        controller: _previewScrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              widget.titleController.text.isEmpty
                  ? 'Untitled'
                  : widget.titleController.text,
              style: AppTheme.editorTitle(context),
            ),
            const SizedBox(height: 16),

            // Divider
            Container(height: 1, color: AppTheme.separator(context)),
            const SizedBox(height: 16),

            // Markdown content
            MarkdownView(data: widget.contentController.text),
          ],
        ),
      ),
    );
  }

  int _getWordCount() {
    final text = widget.contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }
}

/// Save status enum for status bar
enum SaveStatus { saved, saving, unsaved }
