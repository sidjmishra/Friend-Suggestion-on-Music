import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_music_auth/components/alreadyhaveaccount.dart';
import 'package:spotify_music_auth/components/roundedbutton.dart';
import 'package:spotify_music_auth/components/textfieldcontainer.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/login.dart';
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

  Future<bool> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await authService
            .signUpPlay(name.text, email.text, password.text)
            .then((value) {
          print("Testing" + value);
          return true;
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
        return false;
      }

      return false;
    }
    return false;
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "SIGNUP",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/signup.svg",
                      height: size.height * 0.35,
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        validator: (val) {
                          return val!.length < 3 ? 'Enter valid name' : null;
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
                      text: "SIGNUP",
                      press: () {},
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
            ],
          ),
        ),
      ),
    );
  }
}
