import 'package:shared_preferences/shared_preferences.dart';


Future<bool> setLoginStat(bool status) async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.setBool('isLoggedIn', status);
}

Future<bool> getLoginStat() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ??
      false; //if null, default false. if we try to get before set.
}

Future<bool> setUser(String uName) async{
  final prefs = await SharedPreferences.getInstance();

  return prefs.setString('currentUser', uName);
}

 Future<String?> getUser() async {
  final prefs = await SharedPreferences.getInstance();


  return prefs.getString('currentUser');
}
