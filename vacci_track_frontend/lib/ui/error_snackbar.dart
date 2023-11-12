import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ErrorSnackBar extends StatelessWidget {
  final String? errorMessage;
  const ErrorSnackBar({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double autoHeight = deviceHeight * .25;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: autoHeight,
          decoration: const BoxDecoration(
            color: Color(0xFFC72C41),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 40,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Oh snap!",
                      style: TextStyle(
                          fontSize: autoHeight * .15, color: Colors.white),
                    ),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: autoHeight * .12,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
            ),
            child: Stack(
              children: [
                SvgPicture.asset(
                  "assets/svg/bubble.svg",
                  height: 48,
                  width: 40,
                  color: const Color(0xFF801336),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/fail.svg",
                height: 40,
              ),
              Positioned(
                top: 10,
                child: SvgPicture.asset(
                  "assets/svg/cross.svg",
                  height: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
