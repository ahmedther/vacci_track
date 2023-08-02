import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/components/color_schemes.g.dart';
import 'package:vacci_track_frontend/page/home_screen.dart';
import 'package:vacci_track_frontend/page/login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  static const String title = 'Vacci Track';
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    GoRouter router = GoRouter(routes: [
      GoRoute(
        path: HomeScreen.routeName,
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: LoginPage.routeName,
        builder: (context, state) => const LoginPage(),
      )
    ], initialLocation: HomeScreen.routeName);

    return MaterialApp.router(
      title: title,
      theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme(),
          colorScheme: lightColorScheme),
      routerConfig: router,
    );
  }
}
