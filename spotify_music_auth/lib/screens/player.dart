// ignore_for_file: unused_local_variable, unused_field

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:logger/logger.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/spotifyfunctions.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool _loading = false;
  bool _connected = false;
  bool shuffle = false;
  RepeatMode? repeat = RepeatMode.off;

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

  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });

      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: '0d13cfc9b5564ffe92fea35cb587c7c2',
          redirectUrl: 'http://localhost:8000/callback');
      // var result = await SpotifySdk.connectToSpotifyRemote(
      //     clientId: 'fde1b305d84d4def947ebd284e218e49',
      //     redirectUrl: 'http://localhost:8000/callback');
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      setState(() {
        _loading = false;
        _connected = result;
      });
      print(_connected);
    } on PlatformException catch (e) {
      print("Exception:" + e.toString());
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  @override
  void initState() {
    connectToSpotifyRemote();
    super.initState();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        // _connected = result;
        var data = snapshot.data;
        if (data != null) {
          _connected = data.connected;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Play-Connect',
              style: GoogleFonts.openSans(),
            ),
            centerTitle: true,
            backgroundColor: kPrimaryColor,
          ),
          body: !_connected
              ? const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _connected
                        ? playerState(context)
                        : Text(
                            "Spotify not connected",
                            style: GoogleFonts.openSans(),
                          ),
                  ],
                ),
        );
      },
    );
  }

  Widget playerState(BuildContext context) {
    ImageUri? currentTrackImageUri;
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        var playerState = snapshot.data;

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _connected
                  ? spotifyImageWidget(track.imageUri)
                  : Text(
                      'Connect to see an image...',
                      style: GoogleFonts.openSans(),
                    ),
              const Divider(),
              Text(
                '${track.name} - ${track.artist.name}',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(),
              Text(
                'Artist: ${track.artist.name} - ${track.album.name}',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(),
              // Text(
              //   'Album: ${track.album.name}',
              //   textAlign: TextAlign.center,
              //   style: GoogleFonts.openSans(
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              // Text(
              //     'Progress: ${(playerState.playbackPosition ~/ 1000) / 100} / ${(track.duration ~/ 1000) / 100}  '),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  shuffle
                      ? IconButton(
                          icon: LineIcon(
                            LineIcons.random,
                            color: kPrimaryColor,
                          ),
                          tooltip: "Shuffle On",
                          onPressed: () {
                            shuffle = false;
                            setShuffle(shuffle);
                          },
                        )
                      : IconButton(
                          icon: LineIcon(LineIcons.random),
                          tooltip: "Shuffle Off",
                          onPressed: () {
                            shuffle = true;
                            setShuffle(shuffle);
                          },
                        ),
                  const IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: skipPrevious,
                  ),
                  playerState.isPaused
                      ? const IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: resume,
                        )
                      : const IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: pause,
                        ),
                  const IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: skipNext,
                  ),
                  repeat == RepeatMode.off
                      ? IconButton(
                          onPressed: () {
                            repeat = RepeatMode.track;
                            setRepeatMode(repeat!);
                          },
                          tooltip: "Repeat Once",
                          icon: LineIcon(
                            LineIcons.alternateRedo,
                          ),
                        )
                      : repeat == RepeatMode.track
                          ? IconButton(
                              onPressed: () {
                                repeat = RepeatMode.context;
                                setRepeatMode(repeat!);
                              },
                              tooltip: "Repeat Playlist",
                              icon: LineIcon(
                                LineIcons.alternateRedo,
                                color: kPrimaryColor,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                repeat = RepeatMode.off;
                                setRepeatMode(repeat!);
                              },
                              tooltip: "Repeat Off",
                              icon: LineIcon(
                                LineIcons.alternateRedo,
                                color: Colors.purpleAccent,
                              ),
                            ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
      future: SpotifySdk.getImage(
        imageUri: image,
        dimension: ImageDimension.small,
      ),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!);
        } else if (snapshot.hasError) {
          setStatus(snapshot.error.toString());
          return SizedBox(
            width: ImageDimension.small.value.toDouble(),
            height: ImageDimension.small.value.toDouble(),
            child: Center(
                child: Text(
              'Error getting image',
              style: GoogleFonts.openSans(),
            )),
          );
        } else {
          return SizedBox(
            width: ImageDimension.small.value.toDouble(),
            height: ImageDimension.small.value.toDouble(),
            child: Center(
                child: Text(
              'Getting image...',
              style: GoogleFonts.openSans(),
            )),
          );
        }
      },
    );
  }
}
