import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/components/text_style.dart';

InputDecoration dropdownDecoration(
    {String? label, Color color = Colors.black}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 2),
    ),
  );
}

InputDecoration dropdownDecorationAddEmployee({
  Color? color = Colors.black,
  String? label,
  bool? isBold = true,
  double? fontSize,
  bool? isDisabled = false,
}) {
  return InputDecoration(
    label: CustomTextStyle(
        text: label ?? "",
        isBold: isBold!,
        color: isDisabled! ? Colors.grey : Colors.black,
        fontSize: fontSize),
    enabledBorder: UnderlineInputBorder(
      borderSide:
          BorderSide(color: isDisabled ? Colors.grey : Colors.black, width: 2),
    ),
    focusColor: color,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: color!, width: 2),
    ),
  );
}
