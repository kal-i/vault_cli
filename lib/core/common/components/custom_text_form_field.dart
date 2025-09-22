import 'package:flutter/material.dart';

import '../../../config/theme/app_color.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.label,
    this.isObscured = false,
  });

  final TextEditingController? controller;
  final String? label;
  final bool isObscured;

  @override
  Widget build(BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.bodyMedium;

    UnderlineInputBorder underlineInputBorder({
      required Color color,
      double width = 2.0,
    }) => UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );

    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      style: mediumTextStyle,
      decoration: InputDecoration(
        focusedBorder: underlineInputBorder(color: AppColor.lavender),
        errorBorder: underlineInputBorder(color: AppColor.crimson, width: 1.0),
        focusedErrorBorder: underlineInputBorder(color: AppColor.crimson),
        labelText: label,
        labelStyle: mediumTextStyle,
      ),
    );
  }
}
