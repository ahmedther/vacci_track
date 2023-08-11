import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDropDownField extends StatelessWidget {
  double width;
  String hint;
  String? value;
  InputDecoration? decoration;
  void Function(String?)? onSaved = (value) {};
  List<DropdownMenuItem<String>>? items;
  void Function(String?)? onChanged = (value) {};
  String? Function(String?)? validator;
  CustomDropDownField({
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
        onChanged: onChanged,
        onSaved: onSaved,
        items: items,
        validator: validator,
        value: value,
      ),
    );
  }
}
