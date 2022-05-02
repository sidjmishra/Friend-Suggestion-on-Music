// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:spotify_music_auth/main.dart';
import 'package:spotify_music_auth/services/topartists.dart';
import 'package:spotify_music_auth/services/toptracks.dart';
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
        },
        "2": {
          "genres": _user.items![1].genres,
          "name": _user.items![1].name,
        },
        "3": {
          "genres": _user.items![2].genres,
          "name": _user.items![2].name,
        },
        "4": {
          "genres": _user.items![3].genres,
          "name": _user.items![3].name,
        },
        "5": {
          "genres": _user.items![4].genres,
          "name": _user.items![4].name,
        }
      };
      return userMap;
    } on DioError catch (e) {
      print(e);
    }
    return userMap;
  }
}

class TopTracksResponse {
  final String _url =
      "https://api.spotify.com/v1/me/top/tracks?time_range=medium_term&limit=5&offset=5";
  final String accessToken;

  TopTracksResponse({required this.accessToken}) {
    _dio = Dio();
    HttpOverrides.global = MyHttpOverrides();
  }

  late Dio _dio;

  Future<Map<String, dynamic>> userData() async {
    Map<String, dynamic> userMap = {};
    try {
      TopTracks _user;
      Response response = await _dio.get(
        _url,
        options: Options(
          contentType: 'application/json',
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );
      _user = TopTracks.fromJson(response.data);
      userMap = {
        "1": {
          "track": _user.items![0].name,
          "album": _user.items![0].album!.name,
        },
        "2": {
          "track": _user.items![1].name,
          "album": _user.items![1].album!.name,
        },
        "3": {
          "track": _user.items![2].name,
          "album": _user.items![2].album!.name,
        },
        "4": {
          "track": _user.items![3].name,
          "album": _user.items![3].album!.name,
        },
        "5": {
          "track": _user.items![4].name,
          "album": _user.items![4].album!.name,
        }
      };
      return userMap;
    } on DioError catch (e) {
      print(e);
    }
    return userMap;
  }
}
