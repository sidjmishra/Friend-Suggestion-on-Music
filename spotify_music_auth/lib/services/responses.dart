// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:spotify_music_auth/main.dart';
import 'package:spotify_music_auth/services/topartists.dart';
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
            "Authorization": "Bearer $accessToken",
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
      print(userMap);
      return userMap;
    } on DioError catch (e) {
      print(e);
    }
    return userMap;
  }
}

class TopArtistResponse {
  final String _url =
      "https://api.spotify.com/v1/me/top/artists?time_range=medium_term&limit=5&offset=5";
  final String accessToken;

  TopArtistResponse({required this.accessToken}) {
    _dio = Dio();
    HttpOverrides.global = MyHttpOverrides();
  }

  late Dio _dio;

  Future<Map<String, dynamic>> userData() async {
    Map<String, dynamic> userMap = {};
    try {
      TopArtists _user;
      Response response = await _dio.get(
        _url,
        options: Options(
          contentType: 'application/json',
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );
      _user = TopArtists.fromJson(response.data);
      userMap = {
        "1": {
          "genres": _user.items![0].genres,
          "name": _user.items![0].name,
          "popularity": _user.items![0].popularity,
          "uri": _user.items![0].uri,
          "image": _user.items![0].images![0].url,
          "type": _user.items![0].type,
          "id": _user.items![0].id,
          "href": _user.items![0].href,
        },
        "2": {
          "genres": _user.items![1].genres,
          "name": _user.items![1].name,
          "popularity": _user.items![1].popularity,
          "uri": _user.items![1].uri,
          "image": _user.items![1].images![0].url,
          "type": _user.items![1].type,
          "id": _user.items![1].id,
          "href": _user.items![1].href,
        },
        "3": {
          "genres": _user.items![2].genres,
          "name": _user.items![2].name,
          "popularity": _user.items![2].popularity,
          "uri": _user.items![2].uri,
          "image": _user.items![2].images![0].url,
          "type": _user.items![2].type,
          "id": _user.items![2].id,
          "href": _user.items![2].href,
        },
        "4": {
          "genres": _user.items![3].genres,
          "name": _user.items![3].name,
          "popularity": _user.items![3].popularity,
          "uri": _user.items![3].uri,
          "image": _user.items![3].images![0].url,
          "type": _user.items![3].type,
          "id": _user.items![3].id,
          "href": _user.items![3].href,
        },
        "5": {
          "genres": _user.items![4].genres,
          "name": _user.items![4].name,
          "popularity": _user.items![4].popularity,
          "uri": _user.items![4].uri,
          "image": _user.items![4].images![0].url,
          "type": _user.items![4].type,
          "id": _user.items![4].id,
          "href": _user.items![4].href,
        }
      };
      print(userMap);
      return userMap;
    } on DioError catch (e) {
      print(e);
    }
    return userMap;
  }
}
