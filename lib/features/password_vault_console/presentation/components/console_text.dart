import 'package:flutter/material.dart';

class ConsoleText extends StatelessWidget {
  const ConsoleText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Text(text, style: textTheme.bodyMedium),
    );
  }
}
