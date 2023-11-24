import 'package:flutter/material.dart';

class CustomDropDownField extends StatelessWidget {
  final double width;
  final String hint;
  final String? value;
  final InputDecoration? decoration;
  final void Function(String?)? onSaved;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final double? fontSize;
  final Widget? disabledHint;

  const CustomDropDownField({
    super.key,
    this.onSaved,
    this.onChanged,
    this.value,
    this.validator,
    this.decoration,
    this.fontSize,
    this.disabledHint,
    required this.items,
    required this.width,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField(
        disabledHint: disabledHint,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: fontSize),
        decoration: decoration,
        hint: Text(hint,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        isExpanded: true,
        onChanged: onChanged ?? (String? value) {},
        onSaved: onSaved ?? (String? value) {},
        items: items,
        validator: validator,
        value: value,
      ),
    );
  }
}
