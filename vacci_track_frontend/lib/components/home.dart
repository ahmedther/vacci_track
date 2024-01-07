import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vacci_track_frontend/components/color_schemes.g.dart';
import 'package:vacci_track_frontend/page/add_department_page.dart';
import 'package:vacci_track_frontend/page/add_designation_page.dart';
import 'package:vacci_track_frontend/page/add_dose_page.dart';
import 'package:vacci_track_frontend/page/add_facility_page.dart';
import 'package:vacci_track_frontend/page/add_new_employee_page.dart';
import 'package:vacci_track_frontend/page/add_vaccine_page.dart';
import 'package:vacci_track_frontend/page/home_page.dart';
import 'package:vacci_track_frontend/page/login_page.dart';
import 'package:vacci_track_frontend/page/reports_download_page.dart';

//colors #01579b #e91e63 #76997d

class Home extends StatelessWidget {
  static const String title = 'Vacci Track';
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    GoRouter router = GoRouter(routes: [
      GoRoute(
        path: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: LoginPage.routeName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
          path: AddNewEmployee.routeName,
          builder: (context, state) {
            final Map<String, dynamic>? data =
                state.extra as Map<String, dynamic>?;
            return AddNewEmployee(empData: data);
          }),
      GoRoute(
        path: AddNewEmployee.routeName2,
        builder: (context, state) => const AddNewEmployee(),
      ),
      GoRoute(
        path: AddDesignation.routeName,
        builder: (context, state) => const AddDesignation(),
      ),
      GoRoute(
        path: AddDepartment.routeName,
        builder: (context, state) => const AddDepartment(),
      ),
      GoRoute(
        path: AddFacilityPage.routeName,
        builder: (context, state) => const AddFacilityPage(),
      ),
      GoRoute(
        path: AddVaccinePage.routeName,
        builder: (context, state) => const AddVaccinePage(),
      ),
      GoRoute(
        path: AddDosePage.routeName,
        builder: (context, state) => const AddDosePage(),
      ),
      GoRoute(
        path: HomePage.routeName1,
        builder: (context, state) => const HomePage(isDoseAdminPage: true),
      ),
      GoRoute(
        path: HomePage.routeName2,
        builder: (context, state) =>
            const HomePage(isVaccineCompletedPage: true),
      ),
      GoRoute(
        path: DownloadReportsPage.routeName,
        builder: (context, state) => const DownloadReportsPage(),
      ),
    ], initialLocation: HomePage.routeName);

    return MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme(),
          colorScheme: lightColorScheme),
      routerConfig: router,
    );
  }
}
