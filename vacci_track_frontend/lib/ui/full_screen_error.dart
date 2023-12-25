import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';

class CustomErrorWidget extends StatelessWidget {
  final Color uiColor;
  final String message;
  const CustomErrorWidget(
      {this.message =
          "Well! This is Embarrasing.\nThe gremlins 👹 in our system are playing hide and seek. We're on it, promise!",
      required this.uiColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            color: uiColor,
            size: deviceHeight * .4,
          ),
          CustomTextStyle(
              text: message,
              fontSize: deviceHeight * .05,
              isBold: true,
              color: uiColor,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
