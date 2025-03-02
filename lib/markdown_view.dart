import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownView extends StatelessWidget {
  final String data;
  final ScrollController scrollController;
  final double? textScaleFactor;

  const MarkdownView({
    super.key,
    required this.data,
    required this.scrollController,
    this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Markdown(
      data: data,
      styleSheet: MarkdownStyleSheet(
        // Customize your markdown styles here
        h1: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24 * (textScaleFactor ?? 1.0),
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
        h2: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20 * (textScaleFactor ?? 1.0),
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
        h3: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18 * (textScaleFactor ?? 1.0),
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
        p: TextStyle(
          fontSize: 16 * (textScaleFactor ?? 1.0),
          height: 1.5,
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 16 * (textScaleFactor ?? 1.0),
          backgroundColor:
              isDarkMode
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6,
          color:
              isDarkMode
                  ? CupertinoColors.systemBlue.darkColor
                  : CupertinoColors.systemBlue,
        ),
        codeblockDecoration: BoxDecoration(
          color:
              isDarkMode
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      controller: scrollController,
      selectable: true,
      softLineBreak: true,
    );
  }
}
