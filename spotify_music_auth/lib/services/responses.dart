import 'dart:io';

import 'package:dio/dio.dart';
import 'package:spotify_music_auth/main.dart';
import 'package:spotify_music_auth/services/userprofile.dart';

class UserProfileResponse {
  final String _url = "https://api.spotify.com/v1/me";
  final String accessToken;

  UserProfileResponse({required this.accessToken}) {
    _dio = Dio();
    HttpOverrides.global = MyHttpOverrides();
  }

  late Dio _dio;

  Future<Map<String, dynamic>> userData() async {
    Map<String, dynamic> userMap = {};
    try {
      UserProfile _user;
      Response response = await _dio.get(
        _url,
        options: Options(
          contentType: 'application/json',
          headers: {
            "authorization": "Bearer $accessToken",
          },
        ),
      );
      _user = UserProfile.fromJson(response.data);
      userMap = {
        "name": _user.displayName,
        "email": _user.email,
        "id": _user.id,
        "uri": _user.uri,
        "image": _user.images![0].url,
        "type": _user.type,
        "href": _user.href,
      };
    } on DioError catch (e) {
      print(e);
    }
    return userMap;
  }
}
