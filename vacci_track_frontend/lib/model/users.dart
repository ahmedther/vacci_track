class UserData {
  int? id;
  String? fullName;
  String? username;
  String? token;
  bool? isLoggedIn;

  UserData({
    this.id,
    this.fullName,
    this.username,
    this.token,
    this.isLoggedIn,
  });

  @override
  String toString() {
    return 'UserData(id: $id, fullName: $fullName, username: $username, token: $token, isLoggedIn: $isLoggedIn)';
  }
}
