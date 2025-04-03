import 'package:final_project/home_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:final_project/components/input.dart';
import 'package:final_project/components/button.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passkeys/types.dart';
import 'package:passkeys_android/passkeys_android.dart';
import 'package:otp/otp.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
// import 'package:passkeys/types.dart';
part 'passkey.dart';
part 'totp_auth.dart';
part 'passkey_logic.dart';
part 'textfields.dart';
part 'sign.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  // final FlutterSecureStorage storage = FlutterSecureStorage();
  final TextEditingController totpController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isTotpEnabled = false;
  bool isPasskeyEnabled = false;
  bool authTypeSignUp = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 42, 59, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
              // child: FadeInUp(
              //   duration: const Duration(milliseconds: 1200),
              child: Column(
                children: <Widget>[
                  Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(color: Color.fromARGB(255, 23, 8, 6)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(75, 204, 178, 0.2),
                            blurRadius: 20.0,
                            // offset: Offset(0, 10),
                          )
                        ]),
                    child: AuthInputs(
                      emailController: emailController,
                      usernameController: usernameController,
                      passwordController: passwordController,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SquircleButton(
                    textColor: Colors.white,
                    gradient: const LinearGradient(colors: [
                      Color.fromRGBO(46, 140, 109, 1),
                      Color.fromRGBO(121, 191, 172, 1),
                    ]),
                    onTap: () {
                      authTypeSignUp ? signUp(usernameController.text, passwordController.text, context) :
                      signIn(usernameController.text, passwordController.text, context);
                    },
                    title: authTypeSignUp ? "Sign up" : "Sign in",
                  ),
                  // if (isTotpEnabled)
                  //   TextField(
                  //     controller: totpController,
                  //     decoration: InputDecoration(labelText: "TOTP Code"),
                  //   ),
                  // SizedBox(height: 20),
                  // if (isPasskeyEnabled)
                  //   ElevatedButton(
                  //     onPressed: loginWithPasskey,
                  //     child: Text("Login with Passkey"),
                  //   ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          authTypeSignUp = !authTypeSignUp;
                        });
                      },
                      child: Text(
                        authTypeSignUp
                            ? "Already have an account? Sign in"
                            : "Don't have an account? Sign up",
                        style: const TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
            // ),
          ),
        ),
      ),
    );
  }
}
