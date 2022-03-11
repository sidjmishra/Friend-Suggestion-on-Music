// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/models/users.dart';
import 'package:spotify_music_auth/screens/home.dart';
import 'package:spotify_music_auth/services/authenticate.dart';
import 'package:spotify_music_auth/services/database.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String errorMessage;
  late String err;

  PlayUser _userFormFirebaseUser(User? user) {
    return PlayUser(uid: user!.uid);
  }

  Stream<PlayUser> get user {
    return _firebaseAuth.authStateChanges().map(_userFormFirebaseUser);
  }

  handleAuth() {
    return StreamBuilder<PlayUser>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.hasData &&
              snapshot.data!.uid != null) {
            return const HomePage();
          } else if (!snapshot.hasData) {
            return const Authenticate();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future signInPlay(String email, String password) async {
    try {
      User? user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      return _userFormFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      print(error.code);
      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'Your email address appears to be malformed.';
          break;
        case 'wrong-password':
          errorMessage = 'Your password is wrong.';
          break;
        case 'user-not-found':
          errorMessage = "User with this email doesn't exist.";
          break;
        case 'user-disabled':
          errorMessage = 'User with this email has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Signing in with Email and Password is not enabled.';
          break;
        default:
          errorMessage = 'An undefined Error happened.';
      }
      if (errorMessage != '') {
        return Future.error(errorMessage);
      } else {
        return Future.error("Some error occured , Try again later.");
      }
    }
  }

  Future signUpPlay(String name, String email, String password, String username,
      var _imageFile) async {
    try {
      User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      //     .then((userFromDb) async {
      //   PlayUser newUser = PlayUser(
      //     uid: userFromDb.user!.uid,
      //     displayName: name,
      //     email: userFromDb.user!.email,
      //     username: username,
      //   );

      //   await Database().addUserToDatabase(newUser, _imageFile).then((status) {
      //     print("Done");
      //   }).catchError((err) {
      //     print(err.toString());
      //   });
      // });

      if (user != null) {
        PlayUser newUser = PlayUser(
          uid: user.uid,
          displayName: name,
          email: user.email,
          username: username,
        );

        await Database().addUserToDatabase(newUser, _imageFile).then((status) {
          print("Done");
        }).catchError((err) {
          print(err.toString());
        });
      }
      return _userFormFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'Your email address appears to be malformed.';
          break;
        case 'wrong-password':
          errorMessage = 'Your password is wrong.';
          break;
        case 'user-not-found':
          errorMessage = "User with this email doesn't exist.";
          break;
        case 'user-disabled':
          errorMessage = 'User with this email has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email is already in use';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Signing in with Email and Password is not enabled.';
          break;
        default:
          errorMessage = 'An undefined Error happened.';
      }
      if (errorMessage != '') {
        return Future.error(errorMessage);
      } else {
        return Future.error("Some error occured , Try again later.");
      }
    }
  }

  Future signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
