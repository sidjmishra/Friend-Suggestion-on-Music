import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:logger/logger.dart';
import 'package:spotify_music_auth/services/responses.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class SpotAuth extends StatefulWidget {
  const SpotAuth({Key? key}) : super(key: key);

  @override
  State<SpotAuth> createState() => _SpotAuthState();
}

class _SpotAuthState extends State<SpotAuth> {
  String accessToken = "";
  bool _loading = false;
  bool _connected = false;

  String state = "";
  String city = "";

  List tracks = [];
  List albums = [];
  List name = [];
  List genres = [];

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Future<String> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: '0d13cfc9b5564ffe92fea35cb587c7c2',
          redirectUrl: 'http://localhost:8000/callback',
          scope: 'app-remote-control, '
              // 'user-read-private, user-read-email, '
              // 'user-read-playback-position, playlist-modify-public, playlist-modify-private'
              // 'playlist-read-public, playlist-read-private, user-library-read, '
              // 'user-library-modify, user-top-read, playlist-read-collaborative, '
              // 'ugc-image-upload, user-follow-read, user-follow-modify, user-read-playback-state, '
              // 'user-modify-playback-state, user-read-currently-playing, user-read-recently-played'
              'user-modify-playback-state, user-top-read, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      setState(() {
        accessToken = authenticationToken;
      });
      getSpotifyProfile(accessToken);
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  getSpotifyProfile(String accessToken) async {
    Map<String, dynamic> artists =
        await TopArtistResponse(accessToken: accessToken).userData();
    Map<String, dynamic> track =
        await TopTracksResponse(accessToken: accessToken).userData();

    for (var v = 1; v <= 5; v++) {
      for (var i in artists[v.toString()]["genres"]) {
        if (genres.contains(i)) {
          continue;
        } else {
          genres.add(i);
        }
      }
      for (var i in artists[v.toString()]["name"]) {
        if (name.contains(i)) {
          continue;
        } else {
          name.add(i);
        }
      }
      for (var i in track[v.toString()]["album"]) {
        if (albums.contains(i)) {
          continue;
        } else {
          albums.add(i);
        }
      }
      for (var i in track[v.toString()]["track"]) {
        if (tracks.contains(i)) {
          continue;
        } else {
          tracks.add(i);
        }
      }
    }
  }

  getLocation() async {
    loc.LocationData currentPosition;
    String address;
    String dateTime;
    bool serviceEnabled = false;
    loc.PermissionStatus permissionStatus;

    serviceEnabled = await loc.Location().serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await loc.Location().requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionStatus = await loc.Location().hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await loc.Location().requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        return;
      }
    }

    currentPosition = await loc.Location().getLocation();
    print("Latitude: ${currentPosition.latitude}");
    print("Longitude: ${currentPosition.longitude}");

    final coordinates = placemarkFromCoordinates(
        currentPosition.latitude!, currentPosition.longitude!);
    coordinates.then((value) {
      setState(() {
        state = value[0].administrativeArea!;
        city = value[0].subAdministrativeArea!;
      });
    });
  }

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/spotify_icon.png",
                        height: 50.0,
                        width: 50.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * (0.05),
                      ),
                      Text(
                        "Spotify",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 25.0),
                      ),
                    ],
                  ),
                ),
                Text("Connect with Spotify", style: GoogleFonts.poppins()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 60.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 72, 143, 74),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      getAuthenticationToken();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          LineIcon(
                            LineIcons.spotify,
                            size: 30.0,
                          ),
                          Text(
                            "Connect Spotify",
                            style: GoogleFonts.poppins(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
