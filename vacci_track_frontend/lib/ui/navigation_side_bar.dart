import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/ui/navigation_hero.dart';
import 'package:vacci_track_frontend/data/navigationrail_data.dart';
import 'package:vacci_track_frontend/data/other_sub_navigation_rail.dart';
import 'package:vacci_track_frontend/data/vaicnation_navigationrail.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vacci_track_frontend/components/mouse_region_icons.dart';

// ignore: must_be_immutable
class NavigationSideBar extends ConsumerStatefulWidget {
  final UserData userData;
  int? currentIndex = 2;
  Function(int) changePage;
  void Function(dynamic) changeNavIndex;
  NavigationSideBar(
      {super.key,
      required this.userData,
      required this.currentIndex,
      required this.changePage,
      required this.changeNavIndex});

  @override
  ConsumerState<NavigationSideBar> createState() => _NavigationSideBarState();
}

class _NavigationSideBarState extends ConsumerState<NavigationSideBar> {
  bool isOtherHover = false;
  bool isVaccineHover = false;

  void _toggleExtended(event) {
    setState(() {
      isOtherHover = !isOtherHover;
      isVaccineHover = false; // Set the other variable to false
    });
  }

  void _toggleVacineHover(event) {
    setState(() {
      isVaccineHover = !isVaccineHover;
      isOtherHover = false; // Set the other variable to false
    });
  }

  void logoutHandle(BuildContext context, ref) async {
    await Helpers.logoutUser(widget.userData.token);
    Helpers.clearProviderAndPrefs(ref);
    // ignore: use_build_context_synchronously
    context.go('/login');
  }

  void onDestinationOthers(value) {
    widget.changeNavIndex(null);
    value += nagivationList.length;
    widget.changePage(value);
    print(value);
  }

  void onDestinationVaccine(value) {
    widget.changeNavIndex(null);
    value = nagivationList.length + value + otherSubNavigationList.length;
    widget.changePage(value);
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    return Row(
      children: [
        NavigationRail(
          leading: NavigationHero(widget.userData),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomMouseRegionOnNavigationRail(
                  onEnter: _toggleExtended,
                  isHovered: isOtherHover,
                  icon: const FaIcon(
                    FontAwesomeIcons.circlePlus,
                    color: Color(0xFF01579b),
                  ),
                  label: "Add Others"),
              const SizedBox(height: 10),
              CustomMouseRegionOnNavigationRail(
                  onEnter: _toggleVacineHover,
                  isHovered: isVaccineHover,
                  icon: const FaIcon(
                    FontAwesomeIcons.syringe,
                    color: Color(0xFF01579b),
                  ),
                  label: "Add New Vaccine"),
              const SizedBox(height: 10),
              ElevatedButton(
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
            ],
          ),
          selectedIndex: widget.currentIndex,
          onDestinationSelected: (value) {
            widget.changeNavIndex(value);
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
        ),
        if (isOtherHover || isVaccineHover) ...{
          Container(
            width: 0.8, // Width of the border
            color: Colors.black, // Color of the border
          ).animate().fadeIn(delay: 300.ms),
          MouseRegion(
            onExit: isOtherHover ? _toggleExtended : _toggleVacineHover,
            child: NavigationRail(
              groupAlignment: 0.0,
              useIndicator: true,
              labelType: NavigationRailLabelType.all,
              elevation: 10,
              selectedIndex: null,
              indicatorColor: const Color.fromARGB(141, 255, 255, 255),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              destinations: isOtherHover
                  ? otherSubNavigationList
                  : vaccinationNavigationList,
              onDestinationSelected:
                  isOtherHover ? onDestinationOthers : onDestinationVaccine,
            ).animate().slideX().fadeIn().then().shimmer(),
          ),
        },
      ],
    );
  }
}
