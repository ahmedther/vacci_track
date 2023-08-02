import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/model/users.dart';

UserData defaultUserData = UserData(isLoggedIn: false);

class UserNotifier extends StateNotifier<UserData> {
  UserNotifier() : super(defaultUserData) {
    // _initializeDefaultUserData();
  }

  void setUserData(UserData newData) {
    state = newData;
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, UserData>((ref) => UserNotifier());
