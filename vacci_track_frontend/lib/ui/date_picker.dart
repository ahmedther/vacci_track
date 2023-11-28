import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

class CustomDatePicker extends StatelessWidget {
  final double width;
  final DateTime? dateTimeVal;
  final String? defaultLabel;
  final void Function()? onPressed;
  final bool isDisabled;
  final fontSize;

  const CustomDatePicker(
      {this.onPressed,
      this.dateTimeVal,
      this.defaultLabel,
      this.fontSize = 14,
      this.isDisabled = false,
      required this.width,
      super.key});
  Color get color => isDisabled ? Colors.grey : Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDisabled ? color.withOpacity(0.5) : color,
            width: isDisabled ? 1.0 : 2.0,
          ),
        ),
      ),
      alignment: Alignment.center,
      width: width,
      // width: Helpers.min_max(deviceWidth, .12, 163, 300),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextStyle(
            text: dateTimeVal != null
                ? formater.format(dateTimeVal!)
                : defaultLabel ?? "",
            color: color,
            isBold: true,
            fontSize: fontSize,
          ),
          IconButton(
            onPressed: isDisabled ? null : onPressed,
            icon: FaIcon(FontAwesomeIcons.calendarDays, color: color),
          ),
        ],
      ),
    );
  }
}
