import 'package:flutter/material.dart';
import '../../../config/theme/app_color.dart';

class ConsoleText extends StatelessWidget {
  const ConsoleText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bodyMedium =
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontFamily: 'monospace', color: AppColor.primary);

    final errorPattern = RegExp(r'\[ERROR.*?\]|\[UNKNOWN COMMAND.*?\]');
    final successPattern = RegExp(
      r'\[SUCCESS.*?\]|\[FETCHED.*?\]|\[QUESTION.*?\]|\[ENTRY FOUND.*?\]|\[NO VAULT.*?\]',
    );
    final processPattern = RegExp(r'\[PROCESSING.*?\]|\[RETRIEVING.*?\]|\[EXITING.*?\]');
    final commandPattern = RegExp(
      r'\b(init|unlock|recovery|add|list|get|update|delete|lock|clear|exit)\b',
    );
    final flagPattern = RegExp(r'-[a-zA-Z]\b');
    final placeholderPattern = RegExp(r'<[a-zA-Z0-9_ ]+>');
    final informativePattern = RegExp(r'\b(help)\b|\b(tip)\b|\b(next step)\b|\b(cd)\b', caseSensitive: false);


    TextSpan highlightConsoleLine(String text) {
      final spans = <TextSpan>[];
      int start = 0;

      // Helper to add a span

      // Collect matches with priority (errors > success > process > commands > flags > placeholders)
      final matches = <RegExpMatch>[];
      void addMatches(RegExp pattern) {
        for (final match in pattern.allMatches(text)) {
          // Avoid overlaps: only add if not already covered
          if (!matches.any((m) => match.start < m.end && match.end > m.start)) {
            matches.add(match);
          }
        }
      }

      addMatches(errorPattern);
      addMatches(successPattern);
      addMatches(processPattern);
      addMatches(commandPattern);
      addMatches(flagPattern);
      addMatches(placeholderPattern);
      addMatches(informativePattern);

      matches.sort((a, b) => a.start.compareTo(b.start));

      for (final match in matches) {
        // Add default span for text before the match
        if (match.start > start) {
          spans.add(
            TextSpan(
              text: text.substring(start, match.start),
              style: bodyMedium.copyWith(color: AppColor.primary),
            ),
          );
        }

        // Style match by type
        TextStyle style = bodyMedium.copyWith(color: AppColor.primary);
        final matchedText = match[0]!;

        if (errorPattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(color: AppColor.crimson);
        } else if (successPattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(color: AppColor.greenishLight);
        } else if (processPattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(color: AppColor.yellowishDark);
        } else if (commandPattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(
            color: AppColor.lavender,
            fontWeight: FontWeight.bold,
          );
        } else if (flagPattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(
            color: AppColor.mutedRose,
            fontWeight: FontWeight.bold,
          );
        } else if (placeholderPattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(
            color: AppColor.blueish,
            fontWeight: FontWeight.bold,
          );
        } else if (informativePattern.hasMatch(matchedText)) {
          style = bodyMedium.copyWith(
            color: AppColor.yellowish,
            fontWeight: FontWeight.bold,
          );
        } else {
          style = bodyMedium.copyWith(color: AppColor.primary);
        }

        spans.add(TextSpan(text: matchedText, style: style));

        // ✅ Advance `start` so we don’t re-add matched text later
        start = match.end;
      }

      // Add remaining text after last match
      if (start < text.length) {
        spans.add(
          TextSpan(
            text: text.substring(start),
            style: bodyMedium.copyWith(color: AppColor.primary),
          ),
        );
      }

      return TextSpan(children: spans);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: RichText(text: highlightConsoleLine(text)),
    );
  }
}
