import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/navigation_hero.dart';
import 'package:vacci_track_frontend/data/navigationrail_data.dart';
import 'package:vacci_track_frontend/data/other_sub_navigation_rail.dart';
import 'package:vacci_track_frontend/data/vaicnation_navigationrail.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vacci_track_frontend/components/mouse_region_icons.dart';

class NavigationSideBar extends ConsumerStatefulWidget {
  final UserData userData;
  final Color uiColor;
  final Color backgroundColor;

  final void Function() changeUiColor;
  const NavigationSideBar({
    super.key,
    required this.userData,
    required this.uiColor,
    required this.backgroundColor,
    required this.changeUiColor,
  });

  @override
  ConsumerState<NavigationSideBar> createState() => _NavigationSideBarState();
}

class _NavigationSideBarState extends ConsumerState<NavigationSideBar> {
  bool isOtherHover = false;
  bool isVaccineHover = false;
  late int? selectedIndex =
      GoRouter.of(context).routeInformationProvider.value.uri.toString() == "/"
          ? 0
          : ref.watch(navProvider).selectedIndex;
  late int? otherIndex = ref.watch(navProvider).otherIndex;
  late int? vaccineIndex = ref.watch(navProvider).vaccineIndex;

  late final List<NavigationRailDestination> nagivationList =
      getNavigationRailDestinations(widget.uiColor);

  late final List<NavigationRailDestination> otherSubNavigationList =
      getotherSubNavigationList(widget.uiColor);

  late final List<NavigationRailDestination> vaccinationNavigationList =
      getvaccinationNavigationList(widget.uiColor);

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

  void pageChange(int value) {
    const routes = {
      0: '/',
      1: '/record_vaccine_dose',
      2: '/add_new_employee',
      3: '/add_designation',
      4: '/add_department',
      5: '/add_facility',
      6: '/add_vaccine',
      7: '/add_dose',
      
    };

    if (routes.containsKey(value)) {
      context.go(routes[value]!);
    }
  }

  void changeNavIndex(int? value) {
    ref.watch(navProvider.notifier).updatIndex(selectedIndex: value);
  }

  void changeNavIndexOfExtended(bool isOtherHover, int value) {
    isOtherHover
        ? ref.watch(navProvider.notifier).updatIndex(otherIndex: value)
        : ref.watch(navProvider.notifier).updatIndex(vaccineIndex: value);
  }

  void onDestinationOthers(bool isOtherHover, int value) {
    changeNavIndexOfExtended(isOtherHover, value);
    value += nagivationList.length;
    pageChange(value);
  }

  void onDestinationVaccine(bool isOtherHover, int value) {
    changeNavIndexOfExtended(isOtherHover, value);
    value = nagivationList.length + value + otherSubNavigationList.length;
    pageChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          leading: NavigationHero(
            backgroundColor: widget.backgroundColor,
            uiColor: widget.uiColor,
            userData: widget.userData,
            changeUiColor: widget.changeUiColor,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomMouseRegionOnNavigationRail(
                  onEnter: _toggleExtended,
                  isHovered: isOtherHover,
                  icon: FaIcon(
                    FontAwesomeIcons.circlePlus,
                    color: widget.uiColor,
                  ),
                  label: "Add Others"),
              const SizedBox(height: 10),
              CustomMouseRegionOnNavigationRail(
                  onEnter: _toggleVacineHover,
                  isHovered: isVaccineHover,
                  icon: FaIcon(
                    FontAwesomeIcons.syringe,
                    color: widget.uiColor,
                  ),
                  label: "Add New Vaccine"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => logoutHandle(context, ref),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.rightFromBracket,
                      color: widget.uiColor,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(color: widget.uiColor),
                    )
                  ],
                ),
              ),
            ],
          ),
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            changeNavIndex(value);
            pageChange(value);
          },

          indicatorColor: const Color.fromARGB(255, 255, 255, 255),
          backgroundColor: widget.backgroundColor,
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
                selectedIndex: isOtherHover ? otherIndex : vaccineIndex,
                indicatorColor: const Color.fromARGB(141, 255, 255, 255),
                backgroundColor: widget.backgroundColor,
                destinations: isOtherHover
                    ? otherSubNavigationList
                    : vaccinationNavigationList,
                onDestinationSelected: (int value) {
                  isOtherHover
                      ? onDestinationOthers(isOtherHover, value)
                      : onDestinationVaccine(isOtherHover, value);
                }).animate().slideX().fadeIn().then().shimmer(),
          ),
        },
      ],
    );
  }
}
