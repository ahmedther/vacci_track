import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.inputFormatters,
    this.maxLines,
    this.border,
    this.enabled,
    this.uiColor,
    required this.width,
    required this.onSaved,
    required this.label,
  });

  final double width;
  final String label;
  final String? initialValue;
  final int? maxLines;
  final InputBorder? border;
  final bool? enabled;
  final Color? uiColor;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  void returnNull(String? value) {}
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        style: const TextStyle(fontWeight: FontWeight.bold),
        cursorColor: uiColor,
        enabled: enabled,
        inputFormatters: inputFormatters,
        onChanged: onChanged ?? returnNull,
        initialValue: initialValue,
        onSaved: onSaved ?? returnNull,
        maxLines: maxLines,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: uiColor ?? Colors.amber, width: 2.0),
          ),
          // enabledBorder: const OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.red, width: 2.0),
          // ),
          label: Text(label, style: TextStyle(color: uiColor)),
          border: border,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
        validator: validator ?? (String? value) => null,
      ),
    );
  }
}
