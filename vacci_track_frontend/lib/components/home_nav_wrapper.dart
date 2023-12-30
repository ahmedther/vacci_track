import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/nav_wrapper.dart';
import 'package:vacci_track_frontend/data/home_navigation_data.dart';
import 'package:vacci_track_frontend/data/routes.dart';
import 'package:vacci_track_frontend/ui/home_card_heading.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';

class HomeWithNavWrapper extends StatelessWidget {
  final String pageHeading;
  final Color uiColor;
  final Color? backgroundColor;
  final Color themeColor;
  final double containerWidth;
  final double deviceHeight;
  final double deviceWidth;
  final TextEditingController? searchController;
  final void Function()? onPressedSearch;
  final void Function(String)? onChangedSearch;
  final String? searchHintText;
  final List<Widget>? children;
  final List<String> headings;

  const HomeWithNavWrapper(
      {this.backgroundColor,
      this.searchController,
      this.onPressedSearch,
      this.onChangedSearch,
      this.searchHintText,
      this.children,
      required this.themeColor,
      required this.uiColor,
      required this.containerWidth,
      required this.deviceWidth,
      required this.deviceHeight,
      required this.pageHeading,
      required this.headings,
      super.key});


  final int selectedIndex = 1;


  @override
  Widget build(BuildContext context) {
    late final List<NavigationDestination> homeNavigationList =
        getHomNavigationDestination(uiColor);

    return NavWrapper(
      child: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(deviceHeight * .02),
              child: Text(
                pageHeading,
                style: TextStyle(
                  fontSize: deviceHeight * .03,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 30, right: 20, bottom: deviceHeight * .02),
              width: containerWidth * 0.99,
              child: NavigationBar(
                onDestinationSelected: (int value) {
                  if (homeRoutes.containsKey(value)) {
                    context.go(homeRoutes[value]!);
                  }
                },
                indicatorColor: const Color.fromARGB(255, 255, 255, 255),
                animationDuration: const Duration(seconds: 3),
                backgroundColor: themeColor,
                selectedIndex: selectedIndex,
                elevation: 10,
                shadowColor: Colors.black,
                surfaceTintColor: Colors.white,
                destinations: homeNavigationList,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 30, right: 20, bottom: deviceHeight * .02),
              child: CustomSearchBar(
                deviceWidth: deviceWidth,
                controller: searchController,
                onPressed: onPressedSearch,
                uiColor: uiColor,
                backgroundColor: themeColor,
                hintText: searchHintText,
                onChanged: onChangedSearch,
              ),
            ),
            HomeCardHeading(
                containerWidth: containerWidth,
                deviceHeight: deviceHeight,
                deviceWidth: deviceWidth,
                themeColor: themeColor,
                uiColor: uiColor,
                headings: headings),
            ...?children,
          ],
        ),
      ),
    );
  }
}
