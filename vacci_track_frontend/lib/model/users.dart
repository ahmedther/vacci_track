class UserData {
  int? id;
  String? fullName;
  String? username;
  String? gender;
  String? prNumber;
  String? token;
  bool? isLoggedIn;

  UserData({
    this.id,
    this.fullName,
    this.username,
    this.gender,
    this.prNumber,
    this.token,
    this.isLoggedIn,
  });

  @override
  String toString() {
    return 'UserData(id: $id, fullName: $fullName, username: $username, gender:$gender, prNumber : $prNumber,token: $token, isLoggedIn: $isLoggedIn)';
  }
}
