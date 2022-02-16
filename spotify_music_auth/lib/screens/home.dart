import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/auth.dart';
import 'package:spotify_music_auth/services/authenticate.dart';
import 'package:spotify_music_auth/services/responses.dart';
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

  Map<String, dynamic> userData = {};

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

  @override
  void initState() {
    getAuthenticationToken();
    connectToSpotifyRemote();
    UserProfileResponse(accessToken: accessToken)
        .userData()
        .then((value) => {print(value.values)});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play-Connect'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                disconnect();
                AuthService().signOut().then((value) =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Authenticate())));
              }),
        ],
      ),
      body: accessToken == ""
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : Column(
              children: [
                Center(
                  child: Text(userData.values.toString()),
                ),
              ],
            ),
    );
  }
}
