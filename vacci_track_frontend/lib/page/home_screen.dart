import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/data/navigation_pages.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/ui/navigation_side_bar.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/';
  final String title = "Home";
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  UserData userData = UserData(gender: "male", isLoggedIn: false);
  int currentIndex = 7;
  int? navCurrentIndex = 0;
  bool isSpinning = true;

  late Color uiColor =
      Helpers.getUIandBackgroundColor(userData.gender ?? "female")[0];
  // Color uiColor = Helpers.getRandomColor();
  late Color backgroundColor;
  late List<Widget> pages;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkAuthRedirect();

      _pageController = PageController(initialPage: currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void checkAuthRedirect() async {
    userData = await Helpers.checkLogin(ref);
    // ignore: use_build_context_synchronously
    if (userData.isLoggedIn! == false) context.go('/login');
    if (userData.isLoggedIn!) {
      changeTheUI();
      if (mounted) {
        setState(() {
          isSpinning = !userData.isLoggedIn!;
        });
      }
    }
  }

  void pageChange(int value) {
    setState(() {
      currentIndex = value;
    });
  }

  void changeNavIndex(value) {
    navCurrentIndex = value;
  }

  void changeTheUI() {
    uiColor = Helpers.getUIandBackgroundColor(userData.gender!)[0];
    backgroundColor = Helpers.getUIandBackgroundColor(userData.gender!)[1];
    pages = getNaviPages(backgroundColor, uiColor);
  }

  void changeUiColor() async {
    await Helpers.genderChange(ref);
    setState(() {
      changeTheUI();
    });
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
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 1,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      pageSnapping: false,
                      itemBuilder: (context, index) {
                        return pages[currentIndex];
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: NavigationSideBar(
                        uiColor: uiColor,
                        backgroundColor: themeColor,
                        userData: userData,
                        currentIndex: navCurrentIndex,
                        changePage: pageChange,
                        changeNavIndex: changeNavIndex,
                        changeUiColor: changeUiColor),
                  ),
                ],
              ),
      ),
    );
  }
}
