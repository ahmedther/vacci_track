import 'package:flutter/material.dart';

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
