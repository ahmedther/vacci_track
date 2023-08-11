import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CustomInputField extends StatelessWidget {
  CustomInputField({
    super.key,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.inputFormatters,
    this.maxLines,
    this.border,
    required this.width,
    required this.onSaved,
    required this.label,
  });

  double width;
  String label;
  String? initialValue;
  int? maxLines;
  InputBorder? border;
  List<TextInputFormatter>? inputFormatters;
  void Function(String)? onChanged = (value) {};
  void Function(String?)? onSaved = (value) {};
  String? Function(String?)? validator = (value) {
    return null;
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        initialValue: initialValue,
        onSaved: onSaved,
        maxLines: maxLines,
        decoration: InputDecoration(label: Text(label), border: border),
        validator: validator,
      ),
    );
  }
}
