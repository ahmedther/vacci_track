import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/ui/navigation_side_bar.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:vacci_track_frontend/page/add_new_employee_page.dart';
import 'package:vacci_track_frontend/page/add_designation_page.dart';
import 'package:vacci_track_frontend/page/add_department_page.dart';
import 'package:vacci_track_frontend/page/add_facility_page.dart';
import 'package:vacci_track_frontend/page/add_vaccine_page.dart';
import 'package:vacci_track_frontend/page/add_dose_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/';
  final String title = "Home";
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final UserData userData;
  int currentIndex = 0;
  int? navCurrentIndex = 0;
  bool isSpinning = true;
  List<Widget> pages = [
    const Text("Home"),
    const AddNewEmployee(),
    const AddDesignation(),
    const AddDepartment(),
    const AddFacilityPage(),
    const AddVaccinePage(),
    const AddDosePage(),
  ];
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

  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    return Scaffold(
      body: Center(
        child: isSpinning
            ? SpinnerWithOverlay(
                spinnerColor: Theme.of(context).colorScheme.primaryContainer,
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
                        userData: userData,
                        currentIndex: navCurrentIndex,
                        changePage: pageChange,
                        changeNavIndex: changeNavIndex),
                  ),
                ],
              ),
      ),
    );
  }
}
