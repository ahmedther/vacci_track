import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';

class NavigationHero extends StatelessWidget {
  final UserData userData;
  final Color uiColor;
  final Color backgroundColor;
  final void Function() changeUiColor;
  const NavigationHero(
      {required this.userData,
      required this.backgroundColor,
      required this.uiColor,
      required this.changeUiColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Image(
          image: const AssetImage("assets/img/syringe.png"),
          height: deviceHeight * 0.05,
        ),
        AnimatedTextKit(
          isRepeatingAnimation: true,
          repeatForever: true,
          animatedTexts: [
            TypewriterAnimatedText(
              'Vacci Track',
              textStyle: TextStyle(
                color: uiColor,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 1000),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: deviceHeight * 0.02),
          height: Helpers.minAndMax(deviceHeight * .1, 90, 500),
          child: Column(
            children: [
              InkWell(
                highlightColor: uiColor,
                splashColor: uiColor,
                hoverColor: Colors.white,
                child: CircleAvatar(
                  backgroundColor: uiColor,
                  radius: 20,
                  child: CircleAvatar(
                    backgroundColor: backgroundColor,
                    foregroundColor: uiColor,
                    radius: 18,
                    child: const FaIcon(FontAwesomeIcons.userTie),
                  ),
                ),
                onTap: () {
                  changeUiColor();
                  // context.go("/login");
                },
              ),
              AnimatedTextKit(
                isRepeatingAnimation: true,
                repeatForever: true,
                animatedTexts: [
                  RotateAnimatedText(
                    userData.fullName!.split(" ").first,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: uiColor,
                    ),
                  ),
                  RotateAnimatedText(
                    userData.fullName!.split(" ").last,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: uiColor,
                    ),
                  ),
                  RotateAnimatedText(
                    "username: ${userData.username}",
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: uiColor,
                    ),
                  ),
                  RotateAnimatedText(
                    "PR : ${userData.prNumber}",
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: uiColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
