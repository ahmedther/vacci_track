import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vacci_track_frontend/components/text_style.dart';

class SpinnerWithOverlay extends StatelessWidget {
  final Color spinnerColor;
  final double size;
  final String message;

  const SpinnerWithOverlay({
    Key? key,
    this.message = "",
    required this.spinnerColor,
    this.size = 125.0, // Set default value for size parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: false,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCircle(
              color: spinnerColor,
              size: size,
            ),
            CustomTextStyle(
              text: message,
              color: spinnerColor,
              fontSize: 14,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}
