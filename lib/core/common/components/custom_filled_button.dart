import 'package:flutter/material.dart';

import '../../../config/theme/app_color.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    required this.onTap,
    required this.label,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.prefixWidget,
  });

  final VoidCallback onTap;
  final String label;
  final Color? color;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Widget? prefixWidget;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColor.lavender;
    final focusColor = baseColor.withValues(alpha: 0.3);
    final hoverColor = baseColor.withValues(alpha: 0.5);
    final splashColor = baseColor.withValues(alpha: 6.0);
    final borderCircularRadius = BorderRadius.circular(borderRadius ?? 10.0);

    return Material(
      color: Colors.transparent,
      borderRadius: borderCircularRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderCircularRadius,
        focusColor: focusColor,
        hoverColor: hoverColor,
        splashColor: splashColor,
        child: Container(
          width: width,
          height: height ?? 40.0,
          decoration: BoxDecoration(
            borderRadius: borderCircularRadius,
            color: baseColor,
          ),
          child: Row(
            spacing: 8.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ?prefixWidget,
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
