import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyUser extends StatefulWidget {
  const SpotifyUser({Key? key}) : super(key: key);

  @override
  _SpotifyUserState createState() => _SpotifyUserState();
}

class _SpotifyUserState extends State<SpotifyUser> {
  bool _loading = false;
  bool _connected = false;

  String accessToken = "";

  CrossfadeState? crossfadeState;
  late ImageUri? currentTrackImageUri;

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
            title: const Text('Play-Connect'),
            backgroundColor: Colors.grey[900],
            actions: [
              _connected
                  ? IconButton(
                      onPressed: disconnect,
                      icon: const Icon(Icons.exit_to_app),
                    )
                  : Container()
            ],
          ),
          body: flowWidget(context),
        );
      },
    );
  }

  Widget flowWidget(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        _connected
            ? Container()
            : SizedBox(
                height: MediaQuery.of(context).size.height * (1.0),
                child: Image.asset(
                  "assets/cover.jpg",
                  fit: BoxFit.fill,
                  color: Colors.grey,
                  colorBlendMode: BlendMode.overlay,
                ),
              ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: _connected
                  ? buildPlayerContextWidget()
                  : accessToken != ""
                      ? ElevatedButton(
                          onPressed: connectToSpotifyRemote,
                          child: const Text("Connect Spotify"),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: getAuthenticationToken,
                          child: const Text("Get Spotify Access"),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
        _loading
            ? Container(
                color: Colors.black12,
                child: const Center(
                    child: CircularProgressIndicator(
                  color: Colors.green,
                )))
            : const SizedBox(),
      ],
    );
  }

  Widget buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        if (playerContext == null) {
          return const Center(
            child: Text('Not connected'),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Title: ${playerContext.title}'),
            Text('Subtitle: ${playerContext.subtitle}'),
            Text('Type: ${playerContext.type}'),
            // User playlist
            Text('Uri: ${playerContext.uri}'),
          ],
        );
      },
    );
  }

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
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
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

  Future<String> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: '0d13cfc9b5564ffe92fea35cb587c7c2',
          redirectUrl: 'http://localhost:8000/callback',
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      setState(() {
        accessToken = authenticationToken;
      });
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}
