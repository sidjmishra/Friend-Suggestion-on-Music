import 'package:flutter/material.dart';

GoogleSignIn googleSignIn = GoogleSignIn();
Home home = Home();

AppBar header(BuildContext context,
    {bool isAppTitle = false,
    String titleText,
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
          ? Text('')
          : IconButton(
              icon: Icon(Icons.cancel),
              tooltip: 'LOGOUT',
              onPressed:
                  //logout,
                  //(){}
                  home.logout,
            )
    ],
  );
}
