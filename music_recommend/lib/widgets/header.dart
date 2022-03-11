// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_recommend/pages/home.dart';

GoogleSignIn googleSignIn = GoogleSignIn();
Home home = const Home();

AppBar header(BuildContext context,
    {bool isAppTitle = false,
    required String titleText,
    //Giving It A Value Makes It Optional
    removeBackButton = false,
    removeLogoutButton = true}) {
  return AppBar(
    //automaticallyImplyLeading set to  false removes
    // back button. So if remove backButton is true
    // return false and remove it
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "FlutterShare" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
    actions: <Widget>[
      removeLogoutButton
          ? const Text('')
          : IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'LOGOUT',
              onPressed: () {
                googleSignIn.signOut();
                // googleSignIn.signOut().whenComplete(() =>
                //     Navigator.pushReplacement(context,
                //         MaterialPageRoute(builder: (context) => const Home())));
                print("Log out");
              },
            )
    ],
  );
}
