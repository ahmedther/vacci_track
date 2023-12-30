// ignore_for_file: use_build_context_synchronously, duplicate_ignore

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
  bool isSpinning = true;

  late UserData userData;

  // Color uiColor = Helpers.getRandomColor();
  Color? uiColor;
  late Color backgroundColor;
  late final Color themeColor;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkAuthRedirect();
    });
  }

  Future<void> setUiAndBackgroundColor(UserData userData) async {
    final List<Color> colorsUIBack =
        Helpers.getUIandBackgroundColor(userData.gender!);
    uiColor = colorsUIBack.first;
    backgroundColor = colorsUIBack.last;
    themeColor =
        Helpers.getThemeColor(context: context, gender: userData.gender!);
  }

  void checkAuthRedirect() async {
    userData = await Helpers.checkLogin(ref);
    await setUiAndBackgroundColor(userData);
    if (userData.isLoggedIn! == false) {
      context.go('/login');
    }
    if (userData.isLoggedIn!) {
      await Helpers.setNavData(ref);
      if (mounted) {
        setState(() {
          isSpinning = !userData.isLoggedIn!;
        });
      }
    }
  }

  void changeUiColor() async {
    await Helpers.genderChange(ref);
    ref
        .watch(navProvider.notifier)
        .updatIndex(otherIndex: null, selectedIndex: 0, vaccineIndex: null);
    context.go("/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isSpinning
            ? SpinnerWithOverlay(
                spinnerColor: uiColor ?? const Color(0xFF01579b),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    left: 100,
                    child: widget.child,
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: NavigationSideBar(
                        uiColor: uiColor!,
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
