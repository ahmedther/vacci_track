import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpinnerWithOverlay extends StatelessWidget {
  final Color spinnerColor;
  final double size;

  const SpinnerWithOverlay({
    Key? key,
    required this.spinnerColor,
    this.size = 125.0, // Set default value for size parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: false,
      child: Center(
        child: SpinKitFadingCircle(
          color: spinnerColor,
          size: size,
        ),
      ),
    );
  }
}
