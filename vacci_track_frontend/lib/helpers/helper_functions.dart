// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacci_track_frontend/model/users.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/provider/user_provider.dart';

final DateFormat formater = DateFormat('dd-MMM-yyyy');

class Helpers {
  static double minAndMax(double size, minSize, maxSize) {
    if (size < minSize) {
      return minSize;
    } else if (size > maxSize) {
      return maxSize;
    } else {
      return size;
    }
  }

  static String getFormatedDate({String? stringValue, DateTime? dateValue}) {
    if (stringValue != null) {
      return formater.format(DateTime.parse(stringValue));
    } else if (dateValue != null) {
      return formater.format(dateValue);
    }
    return "Not Available";
  }

  static Future<void> setUserValuesONLocalStorage(data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("user_id", int.parse(data['user_id']));
    prefs.setString("fullName", data['user_fullname']);
    prefs.setString("username", data['username']);
    prefs.setString("gender", data['gender']);
    prefs.setString("prNumber", data['pr_number']);
    prefs.setString("token", data['token']);
    prefs.setBool("isLoggedIn", true);
  }

  static Future<UserData> getUserFromLocalStorage(
      SharedPreferences prefs) async {
    UserData userData = UserData(
      id: prefs.getInt("user_id"),
      fullName: prefs.getString('fullName'),
      username: prefs.getString('username'),
      gender: prefs.getString('gender') ?? "male",
      prNumber: prefs.getString('prNumber'),
      token: prefs.getString('token'),
      isLoggedIn: prefs.getBool("isLoggedIn") ?? false,
    );

    return userData;
  }

  static Future load_env() async {
    await dotenv.load(fileName: 'flutter.env');
    String? API_URL = dotenv.env['API_URL'];
    return API_URL;
  }

  static Future get_csrfToken() async {
    // Create an HttpClient instance
    var httpClient = http.Client();
    final API_URL = await load_env();
    try {
      // Get the CSRF token from the server
      var csrfTokenUrl = 'http://$API_URL/api/csrf_token/';
      var response = await http.get(Uri.parse(csrfTokenUrl));
      var responseBody = jsonDecode(response.body);
      String csrfToken = responseBody['csrfToken'];
      httpClient.close();
      Map<String, String?> data = {
        'csrfToken': csrfToken,
      };
      return data;
    } catch (e) {
      // Handle any errors that occur during the request
      Map<String, String?> data = {
        'error': e.toString(),
      };
      return data;
    }
  }

  static Future<Map> loginUser(username, password) async {
    // final csrfToken = await get_csrfToken();
    // if (csrfToken.containsKey('error')) return csrfToken;

    final API_URL = await load_env();
    Map<String, String> data = {
      'username': username,
      'password': password,
    };
    Map getData =
        await makePostRequest(url: "http://$API_URL/api/login/", data: data);
    if (getData.containsKey('error') == false) {
      await setUserValuesONLocalStorage(getData);
    }
    return getData;
  }

  static Future logoutUser(authToken) async {
    // final csrfToken = await get_csrfToken();
    // if (csrfToken.containsKey('error')) return csrfToken;

    final API_URL = await load_env();
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken'
        // 'X-CSRFToken': csrfToken['csrfToken'],
      };

      var response = await http.get(
        Uri.parse('http://$API_URL/api/logout/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Success! Do something with the response
        final Map data = jsonDecode(response.body);
        return data;
      } else {
        final Map data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      Map<String, String?> data = {
        'error': e.toString(),
      };
      return data;
    }
  }

  static Future checkLoggedInPost(authToken) async {
    // final csrfToken = await get_csrfToken();
    // if (csrfToken.containsKey('error')) return csrfToken;
    final API_URL = await load_env();
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken'
        // 'X-CSRFToken': csrfToken['csrfToken'],
      };

      var response = await http.get(
        Uri.parse('http://$API_URL/api/check_login/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Success! Do something with the response
        final Map data = jsonDecode(response.body);
        return data;
      } else {
        final Map data = {"success": false};
        return data;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      final Map data = {"success": false};
      return data;
    }
  }

  static Future<UserData> initializeDefaultUserData(
      SharedPreferences prefs, WidgetRef ref) async {
    final UserData defaultUserData = await getUserFromLocalStorage(prefs);
    ref.watch(userProvider.notifier).setUserData(defaultUserData);
    return defaultUserData;
  }

  static Future checkLogin(WidgetRef ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserData userData = await initializeDefaultUserData(prefs, ref);
    Map data = await Helpers.checkLoggedInPost(userData.token);
    if (data["success"] == false) {
      clearProviderAndPrefs(ref);
      return UserData(gender: "male", isLoggedIn: false);
    }

    // ignore: invalid_use_of_protected_member
    return userData;
  }

  static void clearProviderAndPrefs(WidgetRef ref) async {
    ref.watch(userProvider.notifier).setUserData(UserData(isLoggedIn: false));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static keepOnlyNumbers({value, searchController}) {
    String cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    searchController.value = searchController.value.copyWith(
      text: cleanedValue,
      selection: TextSelection.collapsed(offset: cleanedValue.length),
    );
    return searchController;
  }

  static Future makePostRequest({url, data}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('token');
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Token $authToken',

        // 'X-CSRFToken': csrfToken['csrfToken'],
      };

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Success! Do something with the response
        final Map data = jsonDecode(response.body);
        return data;
      } else {
        final Map data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      Map<String, String?> data = {
        'error': e.toString(),
      };
      return data;
    }
  }

  static Future makeGetRequest(String url,
      {Map<String, dynamic>? query, bool fileResponce = false}) async {
    // final csrfToken = await get_csrfToken();
    // if (csrfToken.containsKey('error')) return csrfToken;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('token');
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken'
        // 'X-CSRFToken': csrfToken['csrfToken'],
      };
      Response response = await http
          .get(
            Uri.parse(url).replace(queryParameters: query),
            headers: headers,
          )
          .timeout(const Duration(minutes: 30));
      if (response.statusCode == 200) {
        // Success! Do something with the response

        if (fileResponce) {
          await fileResponseHandler(
              response.bodyBytes,
              response.headers['content-disposition']
                      ?.split(';')
                      .firstWhere(
                          (element) => element.trim().startsWith('filename='))
                      .split("=")
                      .last ??
                  "Name Not Available");
          return [
            {'error': "Download Successful!!! Please save your file"}
          ];
        }
        final List data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return [
          {'error': "You’ve are logged out. Please Login to continue."}
        ];
      } else {
        final List data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      List data = [
        {
          'error': e.toString(),
        }
      ];
      return data;
    }
  }

  static Future<void> fileResponseHandler(
      Uint8List responseFile, String filename) async {
    html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(html.Blob([responseFile])))
      ..setAttribute('download', "$filename.xlsx")
      ..click();
  }

  static Color getRandomColor() {
    return Colors.primaries[Random().nextInt(Colors.primaries.length)];
    // List<String> colors = [
    //   "#fca311",
    //   "#FFDD00",
    //   "#FF4301",
    //   "#F66B0E",
    //   "#ff006e",
    //   "#F806CC",
    //   "#31E1F7",
    //   "#0096FF",
    //   "#00B7A8",
    //   "#3DB2FF",
    //   "#113CFC",
    //   "#3B44F6",
    //   "#000000",
    //   "#4C0070",
    //   "#8200FF",
    //   "#45046A",
    //   "#FF0000",
    //   "#379237",
    //   "#49FF00",
    //   "#A6CB12",
    //   "#864000",
    //   "#290001",
    //   "#6A492B",
    //   "#696464",
    //   "#414141",
    //   "#FF7F5B"
    // ];

    // Random random = Random();
    // String randomColorCode = colors[random.nextInt(colors.length)];
    // return Color(
    //     int.parse(randomColorCode.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Future genderChange(WidgetRef? ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserData userData = ref!.watch(userProvider);
    userData.gender =
        userData.gender?.toLowerCase() == "male" ? "female" : "male";
    ref.watch(userProvider.notifier).setUserData(userData);
    prefs.setString("gender", userData.gender!);
    await setNavData(ref);

    final API_URL = await Helpers.load_env();
    Helpers.makePostRequest(url: "http://$API_URL/api/edit_app_user/", data: {
      "id": userData.id,
      "gender": userData.gender,
    });
  }

  static List<Color> getUIandBackgroundColor(String gender) {
    final Color uiColor;
    final Color backgroundColor;

    if (gender.toLowerCase() == "male") {
      uiColor = const Color(0xFF01579b);
      backgroundColor = const Color.fromARGB(15, 1, 88, 155);
      return [uiColor, backgroundColor];
    } else {
      uiColor = Colors.pink;
      backgroundColor = const Color.fromARGB(15, 233, 30, 98);
      return [uiColor, backgroundColor];
    }
  }

  static Color getThemeColor(
      {required BuildContext context, required String gender}) {
    return gender.toLowerCase() == 'male'
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;
  }

  static Color getThemeColorWithUIColor(
      {required BuildContext context, required Color uiColor}) {
    return uiColor == const Color(0xFF01579b)
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;
  }

  static Color getGraditentWithGender(String gender) {
    return gender.toLowerCase() == "male"
        ? const Color.fromARGB(255, 47, 114, 165)
        : const Color.fromARGB(255, 237, 68, 124);
  }

  static Future<bool> checkError(Map data, BuildContext context) async {
    if (data.containsKey("error")) {
      context.go("/");
      return true;
    }
    return false;
  }

  static Future<void> setNavData(WidgetRef ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final UserData defaultUserData = await getUserFromLocalStorage(prefs);
    late final List<Color> colorsUIBack =
        getUIandBackgroundColor(defaultUserData.gender!);

    ref.watch(navProvider.notifier).updateColors(
        backgroundColor: colorsUIBack.last, uiColor: colorsUIBack.first);
  }

  static void changeNavIndex(int? value, WidgetRef ref) {
    ref.watch(navProvider.notifier).updatIndex(selectedIndex: value);
  }
}
