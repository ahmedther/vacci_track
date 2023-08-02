import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/model/users.dart';

class NavigationHero extends StatelessWidget {
  const NavigationHero(this.userData, {super.key});
  final UserData userData;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Image(
          image: AssetImage("assets/img/syringe.png"),
          height: deviceHeight * 0.05,
        ),
        AnimatedTextKit(
          isRepeatingAnimation: true,
          repeatForever: true,
          animatedTexts: [
            TypewriterAnimatedText(
              'Vacci Track',
              textStyle: const TextStyle(
                color: Colors.blue,
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
              CircleAvatar(
                backgroundColor: const Color(0xFF01579b),
                radius: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: Helpers.getRandomColor(),
                  radius: 18,
                  child: const FaIcon(FontAwesomeIcons.userTie),
                ),
              ),
              AnimatedTextKit(
                isRepeatingAnimation: true,
                repeatForever: true,
                animatedTexts: [
                  RotateAnimatedText(
                    userData.fullName!.split(" ").first,
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF01579b),
                    ),
                  ),
                  RotateAnimatedText(
                    userData.fullName!.split(" ").last,
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF01579b),
                    ),
                  ),
                  RotateAnimatedText(
                    "username: ${userData.username}",
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF01579b),
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
