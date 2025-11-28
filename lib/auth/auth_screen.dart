import 'package:knotwork/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:knotwork/components/input.dart';
import 'package:knotwork/components/squircle_button.dart';
import 'package:passkeys/types.dart';
import 'package:passkeys_android/passkeys_android.dart';
import 'package:otp/otp.dart';
import 'package:dio/dio.dart';
part 'passkey_screen.dart';
part 'totp_auth.dart';
part 'passkey_logic.dart';
part 'textfields.dart';
part 'auth_logic.dart';

final AUTH_API_URL = dotenv.env['AUTH_API_URL'];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  // final FlutterSecureStorage storage = FlutterSecureStorage();
  final TextEditingController totpController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool authTypeSignUp = true;
  bool isTotpEnabled = true;
  bool isPasskeyEnabled = true;
  bool loggingInWithTotp = false;
  bool loggingInWithPasskey = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 42, 59, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.travel_explore_rounded,
                      size: 300,
                      color: Color.fromRGBO(75, 204, 178, 0.2),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(75, 204, 178, 0.2),
                              blurRadius: 20.0,
                            )
                          ]),
                      child: AuthInputs(
                        emailController:
                            authTypeSignUp ? emailController : null,
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
                        authTypeSignUp
                            ? signUp(
                                usernameController.text,
                                passwordController.text,
                                emailController.text,
                                context)
                            : login(usernameController.text,
                                passwordController.text, context);
                      },
                      title: authTypeSignUp ? "Sign up" : "Log in",
                    ),
                    if(!authTypeSignUp && (isTotpEnabled || isPasskeyEnabled))
                      SizedBox(height: 20),
                    if (!authTypeSignUp && isTotpEnabled && loggingInWithPasskey)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            loggingInWithTotp = true;
                            loggingInWithPasskey = false;
                          });
                        },
                        child: Text(
                          "Log in with Authenticator app",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    if (!authTypeSignUp && isPasskeyEnabled && loggingInWithTotp)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            loggingInWithPasskey = true;
                            loggingInWithTotp = false;
                          });
                        },
                        child: Text(
                          "Log in with Passkey",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
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
      ),
    );
  }
}
