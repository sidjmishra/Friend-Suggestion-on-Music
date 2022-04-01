import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String userLoggedKey = "ISLOGGEDIN";
  static String usserNameKey = "UserNameKey";
  static String displayNameKey = "UserDisplayKey";
  static String uidKey = "UserUidKey";

  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(userLoggedKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(usserNameKey, userName);
  }

  static Future<bool> saveUserDisplaySharedPreference(
      String displayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(displayNameKey, displayName);
  }

  static Future<bool> saveUserUidSharedPreference(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(uidKey, uid);
  }

  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedKey);
  }

  static Future<String?> getUserNameSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(usserNameKey);
  }

  static Future<String?> getUserDisplaySharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNameKey);
  }

  static Future<String?> getUserUidSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(uidKey);
  }
}
