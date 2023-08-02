import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/ui/navigation_hero.dart';
import 'package:vacci_track_frontend/data/navigationrail_data.dart';

class NavigationSideBar extends ConsumerStatefulWidget {
  final UserData userData;
  int currentIndex = 0;
  Function(int) changePage;
  NavigationSideBar(
      {super.key,
      required this.userData,
      required this.currentIndex,
      required this.changePage});

  @override
  ConsumerState<NavigationSideBar> createState() => _NavigationSideBarState();
}

class _NavigationSideBarState extends ConsumerState<NavigationSideBar> {
  bool isOtherHover = false;

  void _toggleExtended() {
    setState(() {
      isOtherHover = !isOtherHover;
    });
  }

  void logoutHandle(BuildContext context, ref) async {
    await Helpers.logoutUser(widget.userData.token);
    Helpers.clearProviderAndPrefs(ref);
    // ignore: use_build_context_synchronously
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    return NavigationRail(
      leading: NavigationHero(widget.userData),
      trailing: ElevatedButton(
        onPressed: () => logoutHandle(context, ref),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: Color(0xFF01579b),
            ),
            Text('Logout')
          ],
        ),
      ),
      selectedIndex: widget.currentIndex,
      onDestinationSelected: (value) {
        widget.changePage(value);
        print(value);
      },
      indicatorColor: const Color.fromARGB(141, 255, 255, 255),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: 10,
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      // minWidth: 10.w,
      destinations: nagivationList,
    );
  }
}
