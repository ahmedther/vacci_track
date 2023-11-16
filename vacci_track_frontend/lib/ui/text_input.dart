import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/dropdown_decoration.dart';

// ignore: must_be_immutable
class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.inputFormatters,
    this.maxLines,
    this.enabled,
    this.underlineBorder = false,
    this.uiColor,
    this.controller,
    this.labelFontSize,
    this.lableIsBold = true,
    required this.width,
    required this.onSaved,
    required this.label,
  });

  final double width;
  final String label;
  final String? initialValue;
  final int? maxLines;
  final bool? enabled;
  final bool? underlineBorder;
  final Color? uiColor;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final double? labelFontSize;
  final bool lableIsBold;

  void returnNull(String? value) {}
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold),
        cursorColor: uiColor,
        enabled: enabled,
        inputFormatters: inputFormatters,
        onChanged: onChanged ?? returnNull,
        initialValue: initialValue,
        onSaved: onSaved ?? returnNull,
        maxLines: maxLines,
        decoration: underlineBorder!
            ? dropdownDecorationAddEmployee(
                color: uiColor,
                label: label,
                fontSize: labelFontSize,
                isBold: lableIsBold,
              )
            : InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: uiColor ?? Colors.amber, width: 2.0),
                ),
                // enabledBorder: const OutlineInputBorder(
                //   borderSide: BorderSide(color: Colors.red, width: 2.0),
                // ),Text(label, style: TextStyle(color: uiColor))
                label: CustomTextStyle(
                    text: label,
                    color: uiColor,
                    fontSize: labelFontSize,
                    isBold: lableIsBold),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
        validator: validator ?? (String? value) => null,
      ),
    );
  }
}
