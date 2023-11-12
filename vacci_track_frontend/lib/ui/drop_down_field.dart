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

  const CustomDropDownField({
    super.key,
    this.onSaved,
    this.onChanged,
    this.value,
    this.validator,
    this.decoration,
    required this.items,
    required this.width,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField(
        decoration: decoration,
        hint: Text(hint),
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
