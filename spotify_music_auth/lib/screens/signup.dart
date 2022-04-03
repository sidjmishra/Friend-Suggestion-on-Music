// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_music_auth/components/alreadyhaveaccount.dart';
import 'package:spotify_music_auth/components/roundedbutton.dart';
import 'package:spotify_music_auth/components/textfieldcontainer.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/login.dart';
import 'package:spotify_music_auth/screens/screens.dart';
import 'package:spotify_music_auth/services/auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isObscure = true;
  String _errorMessage = '';

  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();

  final picker = ImagePicker();
  var _imageFile;

  bool isImage = false;

  List users = [];

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
      isImage = true;
    });
  }

  Future signUp() async {
    if (_formKey.currentState!.validate() && isImage) {
      try {
        await authService
            .signUpPlay(name.text, email.text, password.text, username.text,
                _imageFile ?? "")
            .then((value) {
          if (value != 'error') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Home()));
          }
        }).catchError((err) {
          setState(() {
            print("Error:" + err);
            _errorMessage = err;
          });
        });
      } catch (e) {
        setState(() {
          print(e);
          _errorMessage = e.toString();
        });
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void initState() {
    FirebaseFirestore.instance.collection('Users').get().then((value) {
      for (var v in value.docs) {
        users.add(v["username"]);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: size.height,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/signup_top.png",
                  width: size.width * 0.35,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  "assets/main_bottom.png",
                  width: size.width * 0.25,
                ),
              ),
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "SIGN UP",
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      GestureDetector(
                        onTap: pickImage,
                        child: _imageFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(_imageFile),
                                radius: 40.0,
                              )
                            : const CircleAvatar(
                                backgroundImage: AssetImage("assets/user.png"),
                                radius: 40.0,
                              ),
                      ),
                      isImage
                          ? const SizedBox()
                          : SizedBox(height: size.height * 0.02),
                      isImage
                          ? const Text("")
                          : Text(
                              "TAP TO ADD A PROFILE PICTURE",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                      const Divider(),
                      TextFieldContainer(
                        child: TextFormField(
                          validator: (val) {
                            return val!.length < 3
                                ? 'Enter valid name'
                                : users.contains(val)
                                    ? "Username already exists!"
                                    : null;
                          },
                          keyboardType: TextInputType.name,
                          controller: username,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: kPrimaryColor,
                            ),
                            hintText: "Username",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextFieldContainer(
                        child: TextFormField(
                          validator: (val) {
                            return val!.length < 5 ? 'Enter valid name' : null;
                          },
                          keyboardType: TextInputType.name,
                          controller: name,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: kPrimaryColor,
                            ),
                            hintText: "Your Name",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextFieldContainer(
                        child: TextFormField(
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                    .hasMatch(val!)
                                ? null
                                : 'Enter valid email';
                          },
                          keyboardType: TextInputType.emailAddress,
                          controller: email,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.mail,
                              color: kPrimaryColor,
                            ),
                            hintText: "Your Email",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextFieldContainer(
                        child: TextFormField(
                          validator: (val) {
                            return val!.length < 8 || val.isEmpty
                                ? 'Password should not be less than 8'
                                : null;
                          },
                          controller: password,
                          obscureText: _isObscure,
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                            hintText: "Password",
                            icon: const Icon(
                              Icons.lock,
                              color: kPrimaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: kPrimaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      RoundedButton(
                        text: "SIGN UP",
                        press: signUp,
                      ),
                      SizedBox(height: size.height * 0.03),
                      AlreadyHaveAnAccountCheck(
                        login: false,
                        press: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const LoginPage();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
