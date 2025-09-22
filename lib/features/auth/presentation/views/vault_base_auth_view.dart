import 'package:flutter/material.dart';

class VaultBaseAuthView extends StatelessWidget {
  const VaultBaseAuthView({
    super.key,
    required this.title,
    required this.mainChildWidget,
    this.footerActionWidget,
  });

  final String title;
  final Widget mainChildWidget;
  final Widget? footerActionWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 30.0,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  mainChildWidget,
                ],
              ),
            ),
            ?footerActionWidget,
          ],
        ),
      ),
    );
  }
}
