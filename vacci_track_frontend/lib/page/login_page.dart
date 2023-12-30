import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/ui/input_field.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/provider/user_provider.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  static const String routeName = '/login';
  final String title = "Login";
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String username = "";
  String password = "";
  bool error = true;
  String errorMessage = "This is the error message";
  bool isSpinning = true;

  late final UserData userData;

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
    if (userData.isLoggedIn! == true) context.go('/');
    if (userData.isLoggedIn! == false) {
      setState(() {
        isSpinning = userData.isLoggedIn!;
      });
    }
  }

  void usernameCallback(String data) {
    username = data;
  }

  void passwordCallback(String data) {
    password = data;
  }

  void authInputs(BuildContext context) {
    error = false;
    errorMessage = "";
    if (username.isEmpty) {
      error = true;
      errorMessage += "Username cannot be left empty.";
    }
    ;
    if (password.isEmpty) {
      error = true;
      errorMessage += " Password cannot be left empty.";
    }
    if (error) {
      HelpersWidget.showSnackBar(context, errorMessage);
    }
  }

  void sendLoginRequest(BuildContext contex) async {
    authInputs(context);

    if (error == false) {
      // Authentication is validated
      final Map data = await Helpers.loginUser(username, password);
      if (data.containsKey("error")) {
        error = true;
        errorMessage = data['error']!;
        // ignore: use_build_context_synchronously
        HelpersWidget.showSnackBar(context, errorMessage);
        return;
      }
      UserData userData = UserData(
        id: int.parse(data['user_id']),
        fullName: data['user_fullname'],
        username: data['username'],
        gender: data['gender'],
        prNumber: data['pr_number'],
        token: data['token'],
        isLoggedIn: true,
      );
      Helpers.setNavData(ref);
      ref.watch(userProvider.notifier).setUserData(userData);
      // ignore: use_build_context_synchronously
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isSpinning
        ? const SpinnerWithOverlay(spinnerColor: Colors.blue)
        : Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.lightBlueAccent,
              child: Stack(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.bottomRight,
                    heightFactor: 0.5,
                    widthFactor: 0.5,
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(200.0)),
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                      child: SizedBox(
                        width: 400,
                        height: 400,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 400,
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          if (error)
                            Material(
                                elevation: 10.0,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    "assets/img/syringe.png",
                                    width: 80,
                                    height: 80,
                                  ),
                                )),
                          Form(
                            child: InputField(
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              "Username",
                              dataCallback: usernameCallback,
                            ),
                          ),
                          Form(
                            child: InputField(
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                "Password",
                                obscureText: true,
                                dataCallback: passwordCallback),
                          ),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () => sendLoginRequest(context),
                              child: const Text(
                                "Login",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

// // class LoginPage extends ConsumerWidget {
  

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
    
