import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/navigation_side_bar.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';

class NavWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const NavWrapper({required this.child, super.key});

  @override
  ConsumerState<NavWrapper> createState() => _NavWrapperState();
}

class _NavWrapperState extends ConsumerState<NavWrapper> {
  UserData userData = UserData(gender: "male", isLoggedIn: false);
  bool isSpinning = true;

  late Color uiColor =
      Helpers.getUIandBackgroundColor(userData.gender ?? "female")[0];
  // Color uiColor = Helpers.getRandomColor();
  late Color backgroundColor =
      Helpers.getUIandBackgroundColor(userData.gender ?? "female")[1];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkAuthRedirect();
    });
  }

  void checkAuthRedirect() async {
    userData = await Helpers.checkLogin(ref);
    // ignore: use_build_context_synchronously
    if (userData.isLoggedIn! == false) context.go('/login');
    if (userData.isLoggedIn!) {
      await setNavData();
      if (mounted) {
        setState(() {
          isSpinning = !userData.isLoggedIn!;
        });
      }
    }
  }

  Future<void> setNavData() async {
    uiColor = Helpers.getUIandBackgroundColor(userData.gender!)[0];
    backgroundColor = Helpers.getUIandBackgroundColor(userData.gender!)[1];

    ref
        .watch(navProvider.notifier)
        .updateColors(backgroundColor: backgroundColor, uiColor: uiColor);
  }

  void changeUiColor() async {
    await Helpers.genderChange(ref);
    await setNavData();

    context.go("/login");
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Helpers.getThemeColor(
        context: context, gender: userData.gender ?? "female");

    return Scaffold(
      body: Center(
        child: isSpinning
            ? SpinnerWithOverlay(
                spinnerColor: uiColor,
              )
            : Stack(
                children: [
                  Positioned.fill(
                    left: 120,
                    child: widget.child,
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: NavigationSideBar(
                        uiColor: uiColor,
                        backgroundColor: themeColor,
                        userData: userData,
                        changeUiColor: changeUiColor),
                  ),
                ],
              ),
      ),
    );
  }
}
