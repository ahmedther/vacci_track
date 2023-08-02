import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  double width;
  String label;
  String? initialValue;
  int? maxLines;
  List<TextInputFormatter>? inputFormatters;
  void Function(String)? onChanged = (value) {};
  void Function(String?)? onSaved = (value) {};
  String? Function(String?)? validator = (value) {
    return null;
  };

  CustomInputField({
    super.key,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.inputFormatters,
    this.maxLines,
    required this.width,
    required this.onSaved,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: TextFormField(
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        initialValue: initialValue,
        onSaved: onSaved,
        maxLines: maxLines,
        decoration: InputDecoration(
          label: Text(label),
        ),
        validator: validator,
      ),
    );
  }
}
