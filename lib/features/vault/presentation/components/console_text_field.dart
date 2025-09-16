import 'package:flutter/material.dart';

import '../../../../config/theme/app_color.dart';

class ConsoleTextField extends StatelessWidget {
  const ConsoleTextField({super.key, this.controller, this.onSubmitted});

  final TextEditingController? controller;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColor.primary, width: 1.0)),
      ),
      child: Row(
        children: [
          Text('vault>', style: textTheme.bodyMedium),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              autofocus: true,
              style: textTheme.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
