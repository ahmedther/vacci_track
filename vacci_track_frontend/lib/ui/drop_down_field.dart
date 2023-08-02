import 'package:flutter/material.dart';

class CustomDropDownField extends StatelessWidget {
  double width;
  String hint;
  String? value;
  void Function(String?)? onSaved = (value) {};
  List<DropdownMenuItem<String>>? items;
  void Function(String?)? onChanged = (value) {};
  String? Function(String?)? validator;
  CustomDropDownField({
    super.key,
    this.onSaved,
    this.onChanged,
    this.value,
    required this.items,
    required this.width,
    required this.hint,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: DropdownButtonFormField(
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
