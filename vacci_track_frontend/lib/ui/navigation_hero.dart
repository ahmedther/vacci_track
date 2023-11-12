import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/model/users.dart';

class NavigationHero extends StatelessWidget {
  NavigationHero(this.userData, {super.key});
  final UserData userData;
  late final Color uiColor = Helpers.getThemeColor(userData.gender!);

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
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
          padding: EdgeInsets.only(top: deviceHeight * 0.02),
          height: Helpers.min_max(deviceWidth, 0.12, 106, 120),
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
                    backgroundColor: userData.gender!.toLowerCase() == 'male'
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: uiColor,
                    radius: 18,
                    child: const FaIcon(FontAwesomeIcons.userTie),
                  ),
                ),
                onTap: () {
                  print("THis was CLicked");
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
