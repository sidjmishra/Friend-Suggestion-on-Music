import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:logger/logger.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/constants/helper.dart';
import 'package:spotify_music_auth/screens/chats/chatscreen.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';
import 'package:spotify_music_auth/services/responses.dart';
import 'package:spotify_music_auth/services/spotifyfunctions.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class HomePage extends StatefulWidget {
  // final bool connected;
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String accessToken = "";
  bool _loading = false;
  bool _connected = false;
  // bool shuffle = false;
  // RepeatMode? repeat = RepeatMode.off;

  Map<String, dynamic> userData = {};
  Map<String, dynamic> topArtists = {};

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

  final Logger _logger = Logger(
    //filter: CustomLogFilter(),
    // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  // Future<void> disconnect() async {
  //   try {
  //     setState(() {
  //       _loading = true;
  //     });
  //     var result = await SpotifySdk.disconnect();
  //     setStatus(result ? 'disconnect successful' : 'disconnect failed');
  //     setState(() {
  //       _loading = false;
  //     });
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       _loading = false;
  //     });
  //     setStatus(e.code, message: e.message);
  //   } on MissingPluginException {
  //     setState(() {
  //       _loading = false;
  //     });
  //     setStatus('not implemented');
  //   }
  // }

  // Future<void> connectToSpotifyRemote() async {
  //   try {
  //     setState(() {
  //       _loading = true;
  //     });
  //     var result = await SpotifySdk.connectToSpotifyRemote(
  //         clientId: '0d13cfc9b5564ffe92fea35cb587c7c2',
  //         redirectUrl: 'http://localhost:8000/callback');
  //     setStatus(result
  //         ? 'connect to spotify successful'
  //         : 'connect to spotify failed');
  //     setState(() {
  //       _loading = false;
  //     });
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       _loading = false;
  //     });
  //     setStatus(e.code, message: e.message);
  //   } on MissingPluginException {
  //     setState(() {
  //       _loading = false;
  //     });
  //     setStatus('not implemented');
  //   }
  // }

  Future<String> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: 'fde1b305d84d4def947ebd284e218e49',
          redirectUrl: 'http://localhost:8000/callback',
          scope: 'app-remote-control, '
              // 'user-read-private, user-read-email, '
              // 'user-read-playback-position, playlist-modify-public, playlist-modify-private'
              // 'playlist-read-public, playlist-read-private, user-library-read, '
              // 'user-library-modify, user-top-read, playlist-read-collaborative, '
              // 'ugc-image-upload, user-follow-read, user-follow-modify, user-read-playback-state, '
              // 'user-modify-playback-state, user-read-currently-playing, user-read-recently-played'
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      Map<String, dynamic> data =
          await UserProfileResponse(accessToken: authenticationToken)
              .userData();
      Map<String, dynamic> artists =
          await TopArtistResponse(accessToken: authenticationToken).userData();
      setState(() {
        accessToken = authenticationToken;
        userData = data;
        topArtists = artists;
      });
      print(userData['name']);
      print(topArtists["1"]);
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  getUserInfo() async {
    Constants.uid = HelperFunction.getUserUidSharedPreference().toString();
    Constants.displayName =
        HelperFunction.getUserDisplaySharedPreference().toString();
    Constants.userName =
        HelperFunction.getUserNameSharedPreference().toString();
  }

  @override
  void initState() {
    getAuthenticationToken();
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        _connected = false;
        var data = snapshot.data;
        if (data != null) {
          _connected = data.connected;
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              tooltip: "Logout",
              onPressed: () {
                AuthService().signOut().then((value) =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Authenticate())));
              },
            ),
            title: const Text('Play-Connect'),
            centerTitle: true,
            backgroundColor: kPrimaryColor,
            actions: [
              IconButton(
                icon: LineIcon(LineIcons.rocketChat, color: Colors.white),
                tooltip: "Messages",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatScreen()));
                },
              ),
            ],
          ),
          body: accessToken != ""
              ? const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Spotify connected: $accessToken"),
                  ],
                ),
        );
      },
    );
  }

  // Widget playerState(BuildContext context) {
  //   ImageUri? currentTrackImageUri;
  //   return StreamBuilder<PlayerState>(
  //     stream: SpotifySdk.subscribePlayerState(),
  //     builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
  //       var track = snapshot.data?.track;
  //       currentTrackImageUri = track?.imageUri;
  //       var playerState = snapshot.data;

  //       if (playerState == null || track == null) {
  //         return Center(
  //           child: Container(),
  //         );
  //       }

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             _connected
  //                 ? spotifyImageWidget(track.imageUri)
  //                 : const Text('Connect to see an image...'),
  //             const Divider(),
  //             Text(
  //               '${track.name} - ${track.artist.name}',
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(fontWeight: FontWeight.w500),
  //             ),
  //             const Divider(),
  //             Text(
  //               'Artist: ${track.artist.name} - ${track.album.name}',
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(fontWeight: FontWeight.w500),
  //             ),
  //             const Divider(),
  //             Text(
  //               'Album: ${track.album.name}',
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(fontWeight: FontWeight.w500),
  //             ),
  //             // Text(
  //             //     'Progress: ${(playerState.playbackPosition ~/ 1000) / 100} / ${(track.duration ~/ 1000) / 100}  '),
  //             const Divider(),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 shuffle
  //                     ? IconButton(
  //                         icon: LineIcon(
  //                           LineIcons.random,
  //                           color: kPrimaryColor,
  //                         ),
  //                         tooltip: "Shuffle On",
  //                         onPressed: () {
  //                           shuffle = false;
  //                           setShuffle(shuffle);
  //                         },
  //                       )
  //                     : IconButton(
  //                         icon: LineIcon(LineIcons.random),
  //                         tooltip: "Shuffle Off",
  //                         onPressed: () {
  //                           shuffle = true;
  //                           setShuffle(shuffle);
  //                         },
  //                       ),
  //                 const IconButton(
  //                   icon: Icon(Icons.skip_previous),
  //                   onPressed: skipPrevious,
  //                 ),
  //                 playerState.isPaused
  //                     ? const IconButton(
  //                         icon: Icon(Icons.play_arrow),
  //                         onPressed: resume,
  //                       )
  //                     : const IconButton(
  //                         icon: Icon(Icons.pause),
  //                         onPressed: pause,
  //                       ),
  //                 const IconButton(
  //                   icon: Icon(Icons.skip_next),
  //                   onPressed: skipNext,
  //                 ),
  //                 repeat == RepeatMode.off
  //                     ? IconButton(
  //                         onPressed: () {
  //                           repeat = RepeatMode.track;
  //                           setRepeatMode(repeat!);
  //                         },
  //                         tooltip: "Repeat Once",
  //                         icon: LineIcon(
  //                           LineIcons.alternateRedo,
  //                         ),
  //                       )
  //                     : repeat == RepeatMode.track
  //                         ? IconButton(
  //                             onPressed: () {
  //                               repeat = RepeatMode.context;
  //                               setRepeatMode(repeat!);
  //                             },
  //                             tooltip: "Repeat Playlist",
  //                             icon: LineIcon(
  //                               LineIcons.alternateRedo,
  //                               color: kPrimaryColor,
  //                             ),
  //                           )
  //                         : IconButton(
  //                             onPressed: () {
  //                               repeat = RepeatMode.off;
  //                               setRepeatMode(repeat!);
  //                             },
  //                             tooltip: "Repeat Off",
  //                             icon: LineIcon(
  //                               LineIcons.alternateRedo,
  //                               color: Colors.purpleAccent,
  //                             ),
  //                           ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget spotifyImageWidget(ImageUri image) {
  //   return FutureBuilder(
  //     future: SpotifySdk.getImage(
  //       imageUri: image,
  //       dimension: ImageDimension.small,
  //     ),
  //     builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
  //       if (snapshot.hasData) {
  //         return Image.memory(snapshot.data!);
  //       } else if (snapshot.hasError) {
  //         setStatus(snapshot.error.toString());
  //         return SizedBox(
  //           width: ImageDimension.small.value.toDouble(),
  //           height: ImageDimension.small.value.toDouble(),
  //           child: const Center(child: Text('Error getting image')),
  //         );
  //       } else {
  //         return SizedBox(
  //           width: ImageDimension.small.value.toDouble(),
  //           height: ImageDimension.small.value.toDouble(),
  //           child: const Center(child: Text('Getting image...')),
  //         );
  //       }
  //     },
  //   );
  // }
}
