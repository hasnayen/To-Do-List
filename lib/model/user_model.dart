const String tableUser = 'tblUser';
const String tableUserId = 'userID';
const String tableUserName = 'userName';
const String tableUserPassword = 'userPassword';

class UserModel {
  int? userID;
  String userName, userPassword;

  UserModel({this.userID, required this.userName, required this.userPassword});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      tableUserName: userName,
      tableUserPassword: userPassword,
    };

    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
      userID: map[tableUserId],
      userName: map[tableUserName],
      userPassword: map[tableUserPassword]);

  @override
  String toString() {
    return 'UserModel{userID: $userID, userName: $userName, userPassword: $userPassword}';
  }
}
