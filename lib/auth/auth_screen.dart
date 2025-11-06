import 'package:Knotwork/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:Knotwork/components/input.dart';
import 'package:Knotwork/components/button.dart';
import 'package:passkeys/types.dart';
import 'package:passkeys_android/passkeys_android.dart';
import 'package:otp/otp.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
part 'passkey_screen.dart';
part 'totp_auth.dart';
part 'passkey_logic.dart';
part 'textfields.dart';
part 'auth_logic.dart';

final String AUTH_API_URL=dotenv.env['AUTH_API_URL'] ?? "http://localhost:5000";

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
                        emailController: emailController,
                        usernameController:
                            authTypeSignUp ? usernameController : null,
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
                            ? signUp(usernameController.text,
                                passwordController.text, emailController.text, context)
                            : signIn(usernameController.text,
                                passwordController.text, context);
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
      ),
    );
  }
}
