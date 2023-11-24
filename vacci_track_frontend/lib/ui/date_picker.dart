import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

class CustomDatePicker extends StatelessWidget {
  final double deviceWidth;
  final DateTime? dateTimeVal;
  final String? defaultLabel;
  final void Function()? onPressed;

  const CustomDatePicker(
      {this.onPressed,
      this.dateTimeVal,
      this.defaultLabel,
      required this.deviceWidth,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
      ),
      alignment: Alignment.center,
      width: Helpers.min_max(deviceWidth, .12, 163, 300),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextStyle(
            text: dateTimeVal != null
                ? formater.format(dateTimeVal!)
                : defaultLabel ?? "",
            color: Colors.black,
            isBold: true,
            fontSize: 14,
          ),
          IconButton(
            onPressed: onPressed,

            icon: const FaIcon(FontAwesomeIcons.calendarDays,
                color: Colors.black),
          ),
        ],
      ),
    );
  }
}
